@abstract
class_name BaseAction
extends PlActionTimeManagement

var container: PlayerStatesContainer


var player_sm: PlayerSM


var action_name: String


var blend_time = ActionData.BlendTime.new()
var start_time_offset = ActionData.StartTimeOffset.new()

## do not use this in actions. Use blend_time and start_time_offset features
var _actual_blend_time: float
var _actual_start_time_offset: float


# 
var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()
var motion_type: String ## see MotionType


## assigned while updating current global action as the VERY FIRST operation of the action.
## excessive, but provides an extra gurantee that prev action would not change throughout 
## the current action (self) life cycle.
## => strongly recommended to use this instead of alternative ways like player_sm.get_prev_action
var PREV_ACTION: String = ""


func get_animator_manager() -> PlAnimatorManager:
	return animator_manager


func get_player() -> Princess:
	return player_sm.get_player()
	

func pm() -> PlayerMovement:
	return player_sm.player_movement


# region: INTERFACE 

## if action needs something special to work. Would be called from states container.
## Reason: We rarely can rely on _ready
@abstract func initialise() -> void


func _update(input_: InputPackage, delta: float):
	accumulate_time_spent(delta)
	update(input_, delta)


@abstract func update(input_: InputPackage, delta: float)


func _on_enter_action(input_: InputPackage) -> void:
	mark_enter_state() # NOTE: used word 'state', its ok
	PREV_ACTION = player_sm.update_current_action(self) # NOTE: very first line of curr action
	if self is LegsAction:
		player_sm.legs_sm.set_current_action(self) # very second line
	elif self is PlayerAction:
		player_sm.current_state.curr_state_action = self
	
	on_enter_action(input_)
	animate()


## to override
func on_enter_action(input_: InputPackage) -> void:
	pass


func _on_exit_action() -> void:
	# TODO DANGER: while testing splitted SM, this may work after next action processed _on_enter_action 
	#    this is really bad but almost anything could be set up _on_enter_action and then its ok.
	on_exit_action()


## to override
func on_exit_action() -> void:
	pass


## default implementation. Called automatically.
## Example use cases to override: mute playing animation or overriden values for set_anim_to_play
## NOTE: called AFTER the on_enter_action()
## TODO: DANGER: If an action mutes playing anim (not calling set_anim_to_play), 
## 		TM like time_spent() would stuck and return final values from the previous actions.
## 		Such animations should work with functions like get_real_time_spent or not work with the TM at all.
func animate(): # ▶️
	set_anim_to_play()


func set_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0) -> void:
	_actual_blend_time = blend_time.calculate_actual(PREV_ACTION)
	if override_blend_time != -1.0:
		_actual_blend_time = override_blend_time
	_actual_start_time_offset = start_time_offset.calculate_actual(PREV_ACTION)
	if override_start_time_offset != -1.0:
		_actual_start_time_offset = override_start_time_offset
		
	__log_anim()
	get_animator_manager().set_anim_to_play(anim.anim_id, _actual_blend_time, _actual_start_time_offset)
	# _actual_blend_time = default_blend_time
	# _actual_start_time_offset = default_start_time_offset

# endregion


# region: SPECIFIC TIME MANAGEMENT (TM)

## Like time_remaining(), but takes into account the blend time of the next state.
## It would be needed for a smooth switch.
## NOTE: makes no sense for looping animations => unsupported
## NOTE: less important after modifier started to support multiple blends
## WARNING: does not account for speed scaling
func time_remaining_for_smooth_switch(next_action_name: String) -> float:
	if anim.is_looping:
		print_.warn_raw(false, "Will return big meaningless number: time_remaining_for_smooth_switch does not support looping anims. " + anim.anim_name)
		return Constants.BIG_MEANINGLESS_NUMBER
	var action := container.l_action_by_name(next_action_name)
	var _blend_time: float = action.blend_time.calculate_actual(action_name)
	return max(time_remaining() - _blend_time, 0.0)


## Time remaining till a moment, when current animation would be blended 100%. 
## This is important for the next switch considerations: if A action wants to switch the current B anim, 
## but B is still blending from the previous C animation, there would be a noticable visual snap. 
## Reason: C to B blend would be interrupted by B to A.
## Note: using actual blend duration from manager is better than rely on current action's data or desires.
func till_blend_completes() -> float:
	return max(get_animator_manager().get_curr_blend_duration() - time_spent(), 0.0)

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


func __log_anim():
	print_.any_action_anim(action_name, anim.anim_name, _actual_blend_time, _actual_start_time_offset, PREV_ACTION)
