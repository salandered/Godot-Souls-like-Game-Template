extends PlayerAction

var momentum_preservation := 0.8


func initialise() -> void:
	print_.prefix_s(action_name, "hi", "initialise")
	start_time_offset = anim.get_marker_time_by_name(Marker.Name.LAND_START, default_start_time_offset)


func on_enter_action(input_: InputPackage) -> void:
	# preserve some horizontal momentum from the fall
	__log_action_ent("Landed. XZ/Y speed", get_curr_xz_velocity(), get_curr_y_velocity())
	get_player().velocity.x *= momentum_preservation
	get_player().velocity.z *= momentum_preservation
	__log_action_ent("after momentum_preservation XZ/Y speed", get_curr_xz_velocity(), get_curr_y_velocity())


func update(input_: InputPackage, delta: float) -> void:
	# stick to ground
	get_player().velocity.y = -2.0
	
	# Give control back to the player immediately
	pm().rotate_with_input_vector(input_, delta)
	pm().move_with_input_vector(input_, delta, SpeedConfig.new(default_sp, 1.0))
