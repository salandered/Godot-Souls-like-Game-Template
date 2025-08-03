@tool
@icon("res://-assets-/x_icons/node-colors/purple.png")

extends Node
class_name SplitBodyAnimator

@onready var torso_animator = $TorsoAnim
@onready var legs_animator = $LegsAnim

@export var model: PlayerModel
@export var skeleton: Skeleton3D # MixamoSkeleton
var full_body_mode: bool = true

var synchronization_delta = 0.01


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


func _set_animations():
	if full_body_mode:
		_set_legs_animation(model.current_state.animation)
		_set_torso_animation(model.current_state.animation)
		_synchronize_if_needed()
	else:
		_set_legs_animation(model.legs_manager.current_legs_state.animation)
		_set_torso_animation(model.current_state.animation)


func _set_legs_animation(animation: String):
	#print(legs_animator.current_animation + " changing to " + animation + "_legs")
	legs_animator.play(animation + "_legs")


func _set_torso_animation(animation: String):
	#print(torso_animator.current_animation + " changing to " + animation + "_torso")
	torso_animator.play(animation + "_torso")

# This triggers at the moments of first animation change after exiting TorsoPartialState.
# Imagine we had running legs with 0.5 sec progress, and now we need to Run with full body.
# without this method, torso will start to animate Run from the animation start and will be
# desynced with legs, which will cause gibberish animation
func _synchronize_if_needed():
	if abs(torso_animator.current_animation_position - legs_animator.current_animation_position) > synchronization_delta:
		#print("triggered synchronization")
		torso_animator.seek(legs_animator.current_animation_position)
