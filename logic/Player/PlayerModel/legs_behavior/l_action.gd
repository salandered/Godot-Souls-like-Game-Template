## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends ActionUtils
class_name LegsAction

var player: Princess
var combat: HumanoidCombat
var legs_sm: LegsSM
# var legs_anim_settings: AnimationPlayer

var action_name: String
var animation: String
# @export var anim_settings: String = "simple"
var motion_type: LegsSM.MotionType

var legs_animator: SimpleAnimator_

@export var SPEED: float = 3.0
@export var TURN_SPEED: float = 2.0


# State
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_y_velocity: float = 0.0


func update(_input: InputPackage, _delta: float):
	pass

## can be overriden (see double action)
func animate(previous_action: LegsAction, _input: InputPackage):
	legs_animator.play(animation, 0.2)

func _on_enter_action(input: InputPackage):
	mark_enter_action()
	on_enter_action(input)

func on_enter_action(_input: InputPackage):
	pass

func on_exit_action():
	pass


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	var _velocity := Vector3.ZERO
	var forward_speed := input.forward_input
	var orbit_speed := input.orbit_input

	if legs_sm.area_awareness.is_camera_locked():
		forward_speed *= -1
		orbit_speed *= -1

	var grounded_target: Vector3
	if legs_sm.area_awareness.is_camera_locked():
		grounded_target = player.fancy_camera.locked_target.global_position
	else:
		grounded_target = player.fancy_camera.nest.global_position
	grounded_target.y = player.global_position.y

	if forward_speed != 0.0:
		_velocity -= player.global_position.direction_to(grounded_target) \
					 * forward_speed * SPEED

	if orbit_speed != 0.0:
		var d: float = orbit_speed * SPEED * delta
		var target_direction := grounded_target - player.global_position
		var distance_to_target := target_direction.length()
		var alpha := -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha)
		var d_vector := grounded_target - rotated_dir - player.global_position
		_velocity += d_vector / delta
	return _velocity
