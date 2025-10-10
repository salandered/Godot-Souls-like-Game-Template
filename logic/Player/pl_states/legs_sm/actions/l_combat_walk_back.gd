extends LegsAction

func initialise():
	SPEED = 1.5 # Typically slower than forward


func on_enter_action(_input: InputPackage) -> void:
	print_.lsm_action(action_name, "Target Pos " + pp.vec3(get_player().fancy_camera.locked_target.global_position))


func update(input: InputPackage, delta: float) -> void:
	look_at_target()

	strafe_with_input_vector(input, delta, SpeedConfig.new(1, SPEED))
	# __log_math(input)
	

func animate(): # ▶️
	animator_manager.set_anim_to_play(anim.anim_id, 0.2)


func __log_math(input: InputPackage):
	var log_data = {
		"Input fwd|orbit": pp.s(input.forward_input, "|", input.orbit_input),
		"Player Pos | Fwd Vec": pp.vec3(get_player().global_position) + " " + pp.vec3(-get_player().basis.z),
		"Dir To Target": pp.vec3(get_player().global_position.direction_to(get_player().fancy_camera.locked_target.global_position)),
		"Velocity and speed": pp.vec3(get_player().velocity) + " " + str(get_player().velocity.length()),
	}
	print_.lsm_action(action_name, pp._dict(log_data))