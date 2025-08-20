extends ActionUtils
class_name BaseAction

# var animator_set: String
# var anim_settings: String = "simple"

# SET IN CONTAINER ON INIT
var player: Princess
var states_data_repo: StatesDataRepository

var action_name: String
var animation: String
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
	pass


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

func transitions_to_queued() -> bool:
	return states_data_repo.get_transitions_to_queued(backend_animation, get_progress())

func accepts_queueing() -> bool:
	return states_data_repo.get_accepts_queueing(backend_animation, get_progress())

func tracks_input_vector() -> bool:
	return states_data_repo.tracks_input_vector(backend_animation, get_progress())

func time_til_unlocking() -> float:
	# TODO: delete?
	if tracks_input_vector():
		return 0
	return states_data_repo.time_til_next_controllable_frame(backend_animation, get_progress())

func is_vulnerable() -> bool:
	return states_data_repo.get_vulnerable(backend_animation, get_progress())

func is_interruptable() -> bool:
	return states_data_repo.get_interruptable(backend_animation, get_progress())

func is_parryable() -> bool:
	return states_data_repo.get_parryable(backend_animation, get_progress())

func get_root_position_delta(delta_time: float) -> Vector3:
	return states_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta_time)

func right_weapon_hurts() -> bool:
	return states_data_repo.get_right_weapon_hurts(backend_animation, get_progress())

# END
