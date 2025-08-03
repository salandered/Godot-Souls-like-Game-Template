extends BasePlayerState


var STRAFE_SPEED := 2
func _ready():
	SPEED = 1.5
	TURN_SPEED = 1


func on_enter_state():
	player.look_at(player.fancy_camera.locked_target.global_position)

func default_lifecycle(input: InputPackage):
	if not player.is_on_floor():
		return "midair"
	
	return best_input_that_can_be_paid(input)


func update(_input: InputPackage, _delta: float):
	player.move_and_slide()

func process_input_vector(input: InputPackage, delta: float):
	var move_dir := Vector3.ZERO
	move_dir += -player.fancy_camera.camera.global_transform.basis.z * input.forward_input
	move_dir += player.fancy_camera.camera.global_transform.basis.x * input.orbit_input
	move_dir.y = 0
	move_dir = move_dir.normalized()

	player.velocity = move_dir * STRAFE_SPEED

	player.look_at(player.fancy_camera.locked_target.global_position)


func on_exit_state():
	animator.set_speed_scale(1)


# func _rotate_player_towards_target():
# 	var player_pos = fc.player.global_transform.origin
# 	var target_pos = fc.locked_target.global_transform.origin
# 	var to_target = (target_pos - player_pos).normalized()
# 	to_target.y = 0
# 	if to_target.length() > 0.01:
# 		fc.player.look_at(player_pos - to_target, Vector3.UP)
