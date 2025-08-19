extends ActionUtils
class_name PlayerAction

var player: Princess
#var camera : PlayerCamera
var combat: HumanoidCombat
var player_sm: PlayerSM
# var animations_source: AnimationPlayer
# var torso_anim_settings: AnimationPlayer

var DURATION: float

# var full_body_animator: SimpleAnimator_
var torso_animator: SimpleAnimator_
var legs_animator: SimpleAnimator_
# var animation_settings: AnimationPlayer


# var animator_set: String

var action_name: String
# var anim_settings: String = "simple"
var animation: String
var backend_animation: String
var blend_time: float = 0.2


var animation_duration: float = 0
var states_data_repo: StatesDataRepository

# methods:
# acts_longer_than
# animation_ended
# acts_between

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
	pass

func on_exit_action() -> void:
	# Override per action for cleanup (e.g., clear block flag)
	pass
	
func animate():
	# if animation == "roll" or animation == "block":
		# print_.prefix("~~ SOS", "")
	print_.prefix("▶️ PSM Action ", animation + " with blend time " + str(blend_time), 8)
	torso_animator.play(animation, blend_time)
	# print_.prefix("SKM", "_base _animate with " + animator_set + " settings_switch_time " + str(settings_switch_time))
	# # animator_set - like "full_body" or "torso_legs"
	# if animation_settings.current_animation == animator_set:
	# 	# if pose-to-pose transition inside one modifier -> we use one blending mechanism
	# 	full_body_animator.play(animation, animation_blend_time)
	# else:
	# 	# and if modifier-to-modifier transition -> we switch in modifier poses instantly. 
	# 	full_body_animator.play(animation, 0)
	# # on enter state, settings_animator plays the needed settings template
	# # It's purple node =>  inside the frame, this thing executes before the first sk modifier
	# animation_settings.play(animator_set, settings_switch_time)


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
