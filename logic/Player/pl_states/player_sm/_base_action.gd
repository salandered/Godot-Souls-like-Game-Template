extends ActionUtils
class_name BaseAction

# var animator_set: String
# var anim_settings: String = "simple"

# SET IN CONTAINER ON INIT
var player: Princess
var anim_container: AnimationContainer

var action_name: String
var anim_name: String
var backend_animation: String
var blend_time: float = 0.2

var DURATION: float
# ---

# Possible methods:
# acts_longer_than
# animation_ended
# acts_between


# INTERFACE 

func update(_input: InputPackage, _delta: float):
	u.not_implemented(action_name)


func _on_enter_action(input: InputPackage) -> void:
	mark_enter_action()
	on_enter_action(input)
	animate()

func on_enter_action(_input: InputPackage) -> void:
	pass


func _on_exit_action() -> void:
	on_exit_action()

func on_exit_action() -> void:
	# Override per action for cleanup (e.g., clear block flag)
	pass
	

func animate():
	pass

# INTERFACE ENDS


# GET MODIFIERS BASED ON BACKEND ANIMATION

func _get_current_anim_progress():
	# legs can be leader or double, so probably they always know actual info
	return player.model.legs_animator.get_current_anim_progress()

func switches_to_queue() -> bool:
	var anim = anim_container.get_by_name(anim_name)
	return anim.switches_to_queue(_get_current_anim_progress())

func allows_queue() -> bool:
	var anim = anim_container.get_by_name(anim_name)
	return anim.allows_queue(_get_current_anim_progress())

func is_vulnerable() -> bool:
	var anim = anim_container.get_by_name(anim_name)
	return anim.vulnerable(_get_current_anim_progress())

func is_interruptable() -> bool:
	var anim = anim_container.get_by_name(anim_name)
	return anim.interruptable(_get_current_anim_progress())

func weapon_hurts() -> bool:
	var anim = anim_container.get_by_name(anim_name)
	return anim.weapon_hurts(_get_current_anim_progress())

func tracks_input_vector() -> bool:
	var anim = anim_container.get_by_name(anim_name)
	return anim.tracks_input_vector(_get_current_anim_progress())


# TODO: interesting but do we need this?
# func time_til_unlocking() -> float:
# 	if tracks_input_vector():
# 		return 0
# 	return states_data_repo.time_til_next_controllable_frame(backend_animation, get_progress())
