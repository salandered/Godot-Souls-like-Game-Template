extends PlayerAction

var momentum_preservation := 1.05
var is_landed := false


func initialize() -> void:
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.JUMP.LAND_START, 0.05))

	default_sp.ANGULAR_SPEED = 2.0

	blend_time.set_by_prev_action({
		PS.Act.midair: 0.3
	})


func on_enter_action(input_: InputPackage) -> void:
	is_landed = false
	get_player().velocity.x *= momentum_preservation
	get_player().velocity.z *= momentum_preservation
	__log_ent(pm().__pp_vel())


func update(input_: InputPackage, delta: float) -> void:
	# __log_land()
	if not is_landed:
		pm().apply_gravity(delta)
		if pm().get_area_awareness().is_almost_on_floor():
			is_landed = true

	if tracks_input_vector():
		pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	# pm().move_with_input_vector(input_, delta, SpeedConfig.new(default_sp, 1.0))


func __log_land():
	__log_upd("is_landed", is_landed,
		"player.vel.y", get_player().velocity.y,
		"player.vel", get_player().velocity,
		"player.glob_pos y", get_player().global_position.y
	)
