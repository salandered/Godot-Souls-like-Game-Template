@abstract
class_name BaseAction
extends Node

var player: Princess
var container: PlayerStatesContainer
var anim_container: AnimationContainer
var animator_manager: AnimatorManager

var action_name: String

var anim: AnimationData
var anim_id: String ## same as anim.anim_id
var anim_name: String ## same as anim.anim_name
var default_blend_time: float = 0.2
var DURATION: float ## shortcut for anim.duration

var _enter_action_time: float

# region: TIME MANAGEMENT

func mark_enter_action() -> void:
	_enter_action_time = Time.get_unix_time_from_system()

## Uses real time linear time_spent
func get_progress_real_time() -> float:
	var now = Time.get_unix_time_from_system()
	return now - _enter_action_time

## Uses time_spent from animator, accounts for all speed scales 
## (which can even change dynamically)
func time_spent() -> float:
	return animator_manager.get_current_anim_time_spent()


## NOTE: If it's a looping animation, returns time till next cycle, not an end of the action.
func time_remaining() -> float:
	return DURATION - animator_manager.get_current_anim_time_spent()


## Like time_remaining(), but takes into account the blend time of the next state.
## It would be needed for a smooth switch.
## WARNING: next action's default_blend_time is used!
## NOTE: If it's a looping animation, the function kinda losts its sense, but still valid.
##       It will return the time we have if we wanna switch inside the current cycle.
func time_remaining_for_smooth_switch(next_action_name: String) -> float:
	var action := container.legs_action_by_name(next_action_name)
	return max(DURATION - animator_manager.get_current_anim_time_spent() - action.default_blend_time, 0.0)


## Time remaining till a moment, when current animation would be blended 100%. 
## This important for the next switch considerations: if A action wants to switch the current B one, 
## but current one is still blending from the previous C animation, there would be noticable visual snap. 
## Reason: C to B blend would be interrupted by B to A.
## Note: using actual blend duration from manager is better than rely on current action's data or desires.
func time_remaining_for_blend_to_complete() -> float:
	return max(animator_manager.get_current_blend_duration() - animator_manager.get_current_anim_time_spent(), 0.0)


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
	var progress_ = time_spent()
	if progress_ >= start and progress_ <= finish:
		return true
	return false


func __reject() -> bool:
	# print_.prefix("oooo TM oooo ", "time manage rejected -1", 5)
	return false

# endregion


# region: INTERFACE 

@abstract func update(_input: InputPackage, _delta: float)


func _on_enter_action(input: InputPackage) -> void:
	mark_enter_action()
	on_enter_action(input)
	animate()

func on_enter_action(_input: InputPackage) -> void:
	pass

## NOTE: overriden in LegsAction (may be a hint that abstraction layers not quite there)
func _on_exit_action() -> void:
	on_exit_action()

func on_exit_action() -> void:
	pass
	
## TODO: DANGER: Action must implement set_overlay_anim, otherwise time_spent() 
## would stuck and return final time_spent of the previous action
## For now some action may not use an animation, but then they either should work only with
## get_progress_real_time (and know what they doing), or not working with the time at all.
@abstract func animate() -> void

# endregion


# region: GET ANIMATION PARAMETERS

func switches_to_queue() -> bool:
	return anim.switches_to_queue(time_spent())

func allows_queue() -> bool:
	return anim.allows_queue(time_spent())

func is_vulnerable() -> bool:
	return anim.vulnerable(time_spent())

func is_interruptable() -> bool:
	return anim.interruptable(time_spent())

func weapon_hurts() -> bool:
	return anim.weapon_hurts(time_spent())

func tracks_input_vector() -> bool:
	return anim.tracks_input_vector(time_spent())


# TODO: interesting but do we need this?
# func time_til_unlocking() -> float:
# 	if tracks_input_vector():
# 		return 0
# 	return states_data_repo.time_til_next_controllable_frame(backend_animation, time_spent())


# endregion