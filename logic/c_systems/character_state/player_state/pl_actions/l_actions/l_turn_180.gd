extends BaseLegsTurn

@export var accel_from_apex_curve: Curve

var speed_curve_from_apex := EaseCurveInterpolator.new()


func initialize() -> void:
	super.initialize()
	TURN_180_APEX_TIME = anim.get_marker_time_by_name(MarkerName.TURN_180_APEX, Const.BIG_MEANINGLESS_NUMBER)


func on_enter_action(input_: InputPackage) -> void:
	speed_curve_from_apex.reset()
	
	initial_rotation = get_player().quaternion
	# __log_("~~~ Turn Enter: is_reversed?", input_.reverse_data.is_reversed(), "Input Vec:", input_.input_direction)
	__log_ent("Initial rotation (quaternion)", initial_rotation)
	
	# TURN DATA
	var _target_angle
	if not pm().get_area_awareness().is_camera_locked():
		_target_angle = calculate_target_angle_by_input(input_)
	else:
		_target_angle = calculate_target_angle_by_target(input_)

	var _turn_dir := turn_direction_by_target_angle(_target_angle)
	curr_turn.initialize(_target_angle, _turn_dir)

	# SPEED CONFIG
	speed_curve_from_apex.initialize(accel_from_apex_curve, 0.3)

	match PREV_ACTION:
		Leg.Act.run:
			INCREASE_ROTATION = 1.1
		Leg.Act.idle:
			INCREASE_ROTATION = 1.0
		_:
			INCREASE_ROTATION = 1.0

	
func update(input_: InputPackage, delta: float):
	var SPEED_MULT := 1.0
	if not curr_turn.turn_completed:
		var rotation_delta := get_animator_manager().get_root_rotation()
		var result := pm().apply_root_rotation(rotation_delta * INCREASE_ROTATION, curr_turn.target_angle, curr_turn.accum_rotation)
		curr_turn.update(result.completed, result.accum_rot)
			
	if time_spent() < TURN_180_APEX_TIME:
		var root_vel := get_animator_manager().get_root_velocity()
		get_player().velocity = initial_rotation * root_vel
	else:
		# WARNING: currently turn180-> run configured in a way, that we cut right on apex.
		# => this wont be run, but code is ready to handle this
		SPEED_MULT = speed_curve_from_apex.update(delta)
		__log_action(em.pin, "Life after Apex. time spent | speed mult | pl.vel.len", time_spent(), SPEED_MULT, pm().get_curr_velocity_len())
		pm().move_with_input_vector(input_, delta, SpeedConfig.new(default_sp, SPEED_MULT))


func animate(): # ▶️
	## TODO: some universal system for different "sub animations" in one action
	if curr_turn.is_turn_dir_right():
		anim = anim_container.get_by_anim_id(A.loco.turn_180_R)
	else:
		anim = anim_container.get_by_anim_id(A.loco.turn_180_L)
	set_anim_to_play()
