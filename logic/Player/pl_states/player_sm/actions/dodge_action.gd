extends PlayerAction


@export var dodge_x_curve: Curve # bell-curve

var PEAK_SPEED: float = 6.0
var END_SPEED: float = 2.5
var dodge_x_dur_correction: float = 0.0

var speed_x_interpolator := HillInterpolator.new()


const ANIM_F: String = A.dodge.dodge_F
const ANIM_B: String = A.dodge.dodge_B
const ANIM_R: String = A.dodge.dodge_R
const ANIM_L: String = A.dodge.dodge_L

const SPEED_R: float = 1.0
const SPEED_L: float = 1.0

var curr_dodge_dir: DodgeDirection


func initialise():
	curr_dodge_dir = DodgeDirection.new(SPEED_R, ANIM_R, SPEED_L, ANIM_L, SPEED_R, ANIM_F, SPEED_L, ANIM_B)
	blend_time.set_by_prev_action({
		Leg.Act.run: 0.1, # or 0.1?
	})

	default_sp.ANGULAR_SPEED = 1


func _calculate_anim_effective_duration(actual_anim: AnimationData) -> float:
	var _anim_start := actual_anim.get_marker_time_by_name(Marker.Name_.FROM_RUN, 0.0)
	var _anim_end := actual_anim.get_marker_time_by_name(Marker.Name_.TO_RUN, 1.0)
	start_time_offset.set_specific(_anim_start) # WARNING: important side effect
	return _anim_end - _anim_start


func on_enter_action(input_: InputPackage) -> void:
	var _original_dir: Direction.Dir
	# TODO: while sprinting or not is_camera_locked it almost like another dodge state/action 
	if player_sm.area_awareness.is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		_original_dir = input_.detect_strafe_dir()
	else:
		_original_dir = pm().detect_dir_relative_to_facing(input_, Constants.ONE_FRAME)
	curr_dodge_dir.set_direction_simplified(_original_dir)

	# INTERPOLATOR
	var _inherited_speed := pm().get_curr_velocity_len()
	var _actual_anim := anim_container.get_by_anim_id(curr_dodge_dir.get_curr_anim_id())
	var _anim_effective_dur := _calculate_anim_effective_duration(_actual_anim)

	PEAK_SPEED = 7.0
	END_SPEED = 2.5
	match curr_dodge_dir.get_curr_dir():
		curr_dodge_dir.Dir.FORWARD:
			PEAK_SPEED = 6.0
		curr_dodge_dir.Dir.BACKWARD:
			PEAK_SPEED = 6.0
		curr_dodge_dir.Dir.RIGHT:
			END_SPEED = 2.8
	
	if PREV_ACTION == Leg.Act.sprint:
		PEAK_SPEED = 9
		END_SPEED = 3.5


	speed_x_interpolator.initialise(_inherited_speed, END_SPEED, PEAK_SPEED, dodge_x_curve, _anim_effective_dur + dodge_x_dur_correction)
	
	__log_action_ent("curr_dodge_dir", curr_dodge_dir.pp_curr_dir(),
		"from strafe", Direction.name_(_original_dir),
		"calc_anim_dur", _anim_effective_dur,
	)


func update(input_: InputPackage, delta: float) -> void:
	if player_sm.area_awareness.is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		pm().look_at_target(delta)

	var current_speed := speed_x_interpolator.update(delta)
	
	var _curr_world_vector = curr_dodge_dir.current_world_vector(get_player().basis)
	get_player().velocity = _curr_world_vector * current_speed

	# not in this version
	# if tracks_input_vector():
		# pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))


func animate(): # ▶️
	blend_time.set_specific(0.1)
	
	anim = anim_container.get_by_anim_id(curr_dodge_dir.get_curr_anim_id())
	
	set_anim_to_play()


func _input(event):
	END_SPEED = u._dev_change_param(event, END_SPEED, "END_SPEED", 0.5)
# 	# 	0.5, "dev_speed_down", "dev_speed_up")
# 	VERT_SPEED_BUMP = u._dev_change_t12_param(event, VERT_SPEED_BUMP, "VERT_SPEED_BUMP", 0.5)
# 	GRAVITY_DURING_JUMP = u._dev_change_t58_param(event, GRAVITY_DURING_JUMP, "GRAVITY_DURING_JUMP", 0.5)
