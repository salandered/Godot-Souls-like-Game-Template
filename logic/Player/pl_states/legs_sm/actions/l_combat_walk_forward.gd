extends LegsAction

func initialise():
	SPEED = 1.8 # Tweak as needed


func on_enter_action(_input: InputPackage) -> void:
	print_.lsm_action(action_name, "Target Pos " + pp.vec3(get_player().fancy_camera.locked_target.global_position))

func update(input: InputPackage, delta: float) -> void:
	look_at_target()

	strafe_with_input_vector(input, delta, SpeedConfig.new(1, SPEED))


func animate(): # ▶️
	animator_manager.set_anim_to_play(anim.anim_id, 0.2)
