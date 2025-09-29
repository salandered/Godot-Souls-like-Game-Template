@abstract
class_name BaseAction
extends Node

var player: Princess
var container: PlayerStatesContainer
var anim_container: AnimationContainer
var animator_manager: AnimatorManager

var action_name: String

var anim: AnimationData
var anim_name: String ## same as anim.anim_name
var blend_time: float = 0.2
var DURATION: float ## same as anim.duration

var _enter_action_time: float

# region: TIME MANAGEMENT

func mark_enter_action() -> void:
	_enter_action_time = Time.get_unix_time_from_system()

## Uses real time linear progress
func get_progress_real_time() -> float:
	var now = Time.get_unix_time_from_system()
	return now - _enter_action_time

## Uses progress from animator, accounts for all speed scales 
## (which can even change dynamically)
func get_progress() -> float:
	return animator_manager.get_current_anim_progress()


func time_remaining() -> float:
	## NOTE: If it's a looping animation, returns time till next cycle, not an end of the action.
	return DURATION - animator_manager.get_current_anim_progress()

func time_remaining_for_smooth_switch(next_action_name: String) -> float:
	## Like time_remaining(), but takes into account the blend time of the next state.
	## It would be needed for a smooth switch.
	## NOTE: If it's a looping animation, the function kinda losts its sense, but still valid.
	##       It will return the time we have if we wanna switch inside the current cycle.
	var action := container.legs_action_by_name(next_action_name)
	return DURATION - animator_manager.get_current_anim_progress() - action.blend_time


func works_longer_than(time: float) -> bool:
	if time == -1: return __reject()
	if get_progress() >= time:
		return true
	return false


func works_less_than(time: float) -> bool:
	if time == -1: return __reject()
	if get_progress() < time:
		return true
	return false


func works_between(start: float, finish: float) -> bool:
	if start == -1 or finish == -1: return __reject()
	var progress = get_progress()
	if progress >= start and progress <= finish:
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


func _on_exit_action() -> void:
	on_exit_action()

func on_exit_action() -> void:
	pass
	
## TODO: DANGER: Action must implement set_overlay_anim, otherwise get_progress() 
## would stuck and return final progress of the previous action
## For now some action may not use an animation, but then they either should work only with
## get_progress_real_time (and know what they doing), or not working with the time at all.
@abstract func animate() -> void

# endregion


# region: GET ANIMATION PARAMETERS

func switches_to_queue() -> bool:
	return anim.switches_to_queue(get_progress())

func allows_queue() -> bool:
	return anim.allows_queue(get_progress())

func is_vulnerable() -> bool:
	return anim.vulnerable(get_progress())

func is_interruptable() -> bool:
	return anim.interruptable(get_progress())

func weapon_hurts() -> bool:
	return anim.weapon_hurts(get_progress())

func tracks_input_vector() -> bool:
	return anim.tracks_input_vector(get_progress())


# TODO: interesting but do we need this?
# func time_til_unlocking() -> float:
# 	if tracks_input_vector():
# 		return 0
# 	return states_data_repo.time_til_next_controllable_frame(backend_animation, get_progress())


# endregion