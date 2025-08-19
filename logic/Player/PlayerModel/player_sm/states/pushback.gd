extends PlayerState


@export var movement_multiplier: float = 2

func update(_input: InputPackage, delta: float):
	u.safe_look_at(player, player.global_position + area_awareness.last_pushback_vector)
	
	var delta_pos = current_action.get_root_position_delta(delta)
	delta_pos.y = 0
	player.velocity = (player.get_quaternion() * delta_pos / delta) * movement_multiplier
	if not player.is_on_floor():
		player.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	player.move_and_slide()
