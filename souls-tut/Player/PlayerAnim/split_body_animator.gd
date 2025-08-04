@tool
@icon("res://-assets-/x_icons/node-colors/purple.png")

extends Node
class_name SplitBodyAnimator


@onready var torso_animator: AnimationPlayer = $TorsoAnim
@onready var legs_animator: AnimationPlayer = $LegsAnim

@export var model: PlayerModel
@export var skeleton: Skeleton3D
var full_body_mode: bool = true

var synchronization_delta = 0.01

func _ready():
	configure_blending_times()


func configure_blending_times():
	_set_blend_time(A.strafe_R, A.strafe_L, 0.5)
	# _set_blend_time("ss_strafe/strafe_L", "ss_strafe/strafe_R", 0.5)
	_set_blend_time(A.strafe_R, A.strafe_idle, 0.5)
	_set_blend_time(A.strafe_L, A.strafe_idle, 0.5)
	_set_blend_time(A.strafe_R, A.strafe_forward, 0.5)
	_set_blend_time(A.strafe_L, A.strafe_back, 0.5)
	_set_blend_time(A.idle_longsword, A.strafe_idle, 1)
	_set_blend_time(A.strafe_idle, A.idle_longsword, 1)
	#_set_blend_time("jump_sprint", "midair", 0.5)
	#_set_blend_time("landing_run", "sprint", 0.3)
	#_set_blend_time("landing_sprint", A.run, 0.3)
	#_set_blend_time("idle", "longsword_1", 0.5)
	#_set_blend_time("idle", "parry", 0.3)
	#_set_blend_time("parry", "idle", 0.3)
	#_set_blend_time("longsword_1", "idle_longsword", 0.8)
	#_set_blend_time("longsword_1", A.run, 0.3)
	#_set_blend_time("longsword_1", "sprint", 0.3)
	#_set_blend_time("longsword_1", "longsword_2", 0.3)


func _set_blend_time(from: String, to: String, time: float):
	u.assert_has_animation(torso_animator, from + "_torso")
	u.assert_has_animation(torso_animator, to + "_torso")
	u.assert_has_animation(legs_animator, from + "_legs")
	u.assert_has_animation(legs_animator, to + "_legs")
	torso_animator.set_blend_time(from + "_torso", to + "_torso", time)
	legs_animator.set_blend_time(from + "_legs", to + "_legs", time)

func update_body_animations():
	_update_playmode()
	_set_animations()


func update_legs_animation():
	_update_playmode()
	_set_legs_animation(model.legs_manager.current_legs_state.animation)


func set_speed_scale(speed: float):
	legs_animator.speed_scale = speed
	torso_animator.speed_scale = speed


func reset_torso_animation():
	torso_animator.seek(0)

func reset_legs_animation():
	legs_animator.seek(0)


func _update_playmode():
	if model.current_state is TorsoPartialState:
		full_body_mode = false
	else:
		full_body_mode = true

func __play_not_splitted(animation: String, custom_speed: float = 1.0):
	# TODO: DANGER temporary method for invokin animator in random places...
	legs_animator.stop()
	torso_animator.stop()
	legs_animator.play(animation, custom_speed)

func __set_custom_animations(animation, full_body_mode_: bool = true):
	# TODO: temporary method for invokin animator in random places...
	if full_body_mode_:
		_set_legs_animation(animation)
		_set_torso_animation(animation)
		_synchronize_if_needed()
	else:
		# probably support only full_body_mode_
		_set_legs_animation(model.legs_manager.current_legs_state.animation)
		_set_torso_animation(animation)

func _set_animations():
	if full_body_mode:
		_set_legs_animation(model.current_state.animation)
		_set_torso_animation(model.current_state.animation)
		_synchronize_if_needed()
	else:
		_set_legs_animation(model.legs_manager.current_legs_state.animation)
		_set_torso_animation(model.current_state.animation)


func _set_legs_animation(animation: String):
	var animation_name = animation + "_legs"
	# print_._prefix("Anim", legs_animator.current_animation + " changing to " + animation_name)
	u.assert_has_animation(legs_animator, animation_name)
	legs_animator.play(animation_name)


func _set_torso_animation(animation: String):
	var animation_name = animation + "_torso"
	# print_._prefix("Anim", torso_animator.current_animation + " changing to " + animation_name)
	u.assert_has_animation(torso_animator, animation_name)
	torso_animator.play(animation_name)

# This triggers at the moments of first animation change after exiting TorsoPartialState.
# Imagine we had running legs with 0.5 sec progress, and now we need to Run with full body.
# without this method, torso will start to animate Run from the animation start and will be
# desynced with legs, which will cause gibberish animation
func _synchronize_if_needed():
	if abs(torso_animator.current_animation_position - legs_animator.current_animation_position) > synchronization_delta:
		#print("triggered synchronization")
		torso_animator.seek(legs_animator.current_animation_position)
