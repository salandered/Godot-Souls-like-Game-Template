extends PlayerAction


var jump_direction: Vector3 = Vector3.ZERO


func initialise() -> void:
	blend_time_by_action = {
		PS.Act.jump_sprint: 0.5
	}

func on_enter_action(input_: InputPackage) -> void:
		# the clamp construction:
		#    scale from velocity. The longer the vector is, the harder it is to modify it by adding a delta.
		#    Scaling jump_direction with velocity is giving us that natural behavior of faster jumps (sprints)
		#    being less controllable, and jumps from standing position being more volatile.
	jump_direction = Vector3(get_player().basis.z) * clamp(pm().get_curr_velocity_len(), 1.0, Constants.BIG_MEANINGLESS_NUMBER)
	jump_direction.y = 0
	__log_action_ent("Starting vel:", pm().get_curr_velocity_len(), "jump_direction", jump_direction)


func update(input_: InputPackage, delta: float) -> void:
	pm().apply_gravity(delta)
	pm().process_input_vector_air(input_, delta, jump_direction)
