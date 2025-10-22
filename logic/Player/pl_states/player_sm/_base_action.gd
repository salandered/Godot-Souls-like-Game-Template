@abstract
class_name BaseAction
extends Node

var container: PlayerStatesContainer
var anim_container: BaseAnimationContainer
var animator_manager: AnimatorManager
var player_sm: PlayerSM


var action_name: String
var anim: AnimationData


# anim parameters
var start_time_offset_by_action := {}
var blend_time_by_action := {}

var blend_time: float = 0.2
var start_time_offset: float = 0.0

const default_blend_time: float = 0.2
const default_start_time_offset: float = 0.0

# 
var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()

#
var _enter_action_time: float


## assigned while updating current global action as the VERY FIRST operation of the action.
## excessive, but provides an extra gurantee that prev action would not change throughout 
## the current action (self) life cycle.
## => strongly recommended to use this instead of alternative ways like player_sm.get_prev_action
var PREV_ACTION: String = ""


func get_player() -> Princess:
	return player_sm.get_player()
	
func get_curr_velocity() -> float:
	return get_player().velocity.length()

func get_curr_xz_velocity() -> float:
	return Vector3(get_player().velocity.x, 0, get_player().velocity.z).length()

func get_curr_y_velocity() -> float:
	return Vector3(0, get_player().velocity.y, 0).length()


func pm() -> PlayerMovement:
	return player_sm.player_movement


# region: INTERFACE 

## if action needs something special to work. Would be called from states container.
## Reason: We rarely can rely on _ready
@abstract func initialise() -> void


@abstract func update(input_: InputPackage, _delta: float)


func _on_enter_action(input_: InputPackage) -> void:
	PREV_ACTION = player_sm.update_current_action(self) # NOTE: very first line of curr action
	if self is LegsAction:
		player_sm.legs_sm.set_current_action(self) # very second line
	elif self is PlayerAction:
		player_sm.current_state.curr_state_action = self
	mark_enter_action()
	on_enter_action(input_)
	animate()


## to override
func on_enter_action(input_: InputPackage) -> void:
	pass


func _on_exit_action() -> void:
	on_exit_action()


## to override
func on_exit_action() -> void:
	pass
	
	
## default implementation. Called automatically.
## Example use cases to override: mute playing animation or using situational blend_time.
## NOTE: called AFTER the on_enter_action()
## TODO: DANGER: If an action mutes playing anim (not calling set_anim_to_play), 
## TM like time_spent() would stuck and return final values from the previous actions.
## Such animations should work with functions like get_real_time_spent or not work with the TM at all.
func animate(): # ▶️
	# if action set some specific value, we should not override it using dict, which would probably result in default
	if blend_time == default_blend_time:
		blend_time = blend_time_by_action.get(PREV_ACTION, default_blend_time)
	if start_time_offset == default_start_time_offset:
		start_time_offset = start_time_offset_by_action.get(PREV_ACTION, default_start_time_offset)
	
	set_anim_to_play()

## strongly recommended to use from overriden animate()
func set_anim_to_play():
	__log_anim()
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)

# endregion


# region: TIME MANAGEMENT (TM)

func mark_enter_action() -> void:
	_enter_action_time = Time.get_unix_time_from_system()


## needs mark_enter_action to be set beforehand
func get_real_time_spent() -> float:
	var now := Time.get_unix_time_from_system()
	return now - _enter_action_time


func _effective_duration() -> float:
	return animator_manager.get_curr_anim_effective_duration()


## Use this for comparison with absolute data (native anim timings). 
## Usually it's a work with the markers.
## Accounts for all speed scales 
## May start with start offsets
func effective_time_spent() -> float: # ✔️
	return animator_manager.get_current_anim_effective_progress()


## Use this for working with relative data (animator's timeline).
## Example: working with blend times.
## Time_spent starts with 0.
## Accounts for all speed scales 
func time_spent() -> float: # ✔️
	return animator_manager.get_curr_anim_time_spent()


## NOTE: in case of looping animations returns big number
func time_remaining() -> float: # ✔️
	if anim.is_looping:
		return Constants.BIG_MEANINGLESS_NUMBER
	return _effective_duration() - time_spent() # or: duration - eff time spent


## Like time_remaining(), but takes into account the blend time of the next state.
## It would be needed for a smooth switch.
## NOTE: makes no sense for looping animations => unsupported
## WARNING TODO: does not account for speed scaling
func time_remaining_for_smooth_switch(next_action_name: String) -> float:
	if anim.is_looping:
		print_.warn("Will return big meaningless number: time_remaining_for_smooth_switch does not support looping anims. " + anim.anim_name)
		return Constants.BIG_MEANINGLESS_NUMBER
	var action := container.l_action_by_name(next_action_name)
	var _blend_time: float = action.blend_time_by_action.get(action_name, action.default_blend_time)
	return max(time_remaining() - _blend_time, 0.0)


## Time remaining till a moment, when current animation would be blended 100%. 
## This is important for the next switch considerations: if A action wants to switch the current B anim, 
## but B is still blending from the previous C animation, there would be a noticable visual snap. 
## Reason: C to B blend would be interrupted by B to A.
## Note: using actual blend duration from manager is better than rely on current action's data or desires.
func till_blend_completes() -> float:
	return max(animator_manager.get_curr_blend_duration() - time_spent(), 0.0)


func works_longer_than(time: float) -> bool:
	if time == -1: return __reject()
	if time_spent() >= time:
		return true
	return false


func works_less_than(time: float) -> bool:
	if time == -1: return __reject()
	if time_spent() < time:
		return true
	return false


func works_between(start: float, finish: float) -> bool:
	if start == -1 or finish == -1: return __reject()
	if time_spent() >= start and time_spent() <= finish:
		return true
	return false


func passed_marker(marker_name: String) -> bool:
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		print_.warn("passed_marker - no time - will return false", true)
		return __reject()

	if effective_time_spent() >= marker_time:
		return true
	return false


func before_marker(marker_name: String) -> bool:
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		print_.warn("before_marker - no time - will return false", true)
		return __reject()

	if effective_time_spent() < marker_time:
		return true
	return false


func __reject() -> bool:
	print_.warn("TM rejected -1!")
	return false

# endregion


# region: GET ANIMATION PARAMETERS

func switches_to_queue() -> bool:
	return anim.switches_to_queue(effective_time_spent())

func allows_queue() -> bool:
	return anim.allows_queue(effective_time_spent())

func is_vulnerable() -> bool:
	return anim.vulnerable(effective_time_spent())

func is_interruptable() -> bool:
	return anim.interruptable(effective_time_spent())

func weapon_hurts() -> bool:
	return anim.weapon_hurts(effective_time_spent())

func tracks_input_vector() -> bool:
	return anim.tracks_input_vector(effective_time_spent())


# TODO: interesting but do we need this?
# func time_til_unlocking() -> float:
# 	if tracks_input_vector():
# 		return 0
# 	return states_data_repo.time_til_next_controllable_frame(backend_animation, time_spent())

# endregion


func __log_anim():
	print_.lsm_action_anim(action_name, anim.anim_name, blend_time, start_time_offset, PREV_ACTION)
