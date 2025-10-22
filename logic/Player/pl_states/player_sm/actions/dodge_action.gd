extends PlayerAction


@export var dodge_x_curve: Curve

var dodge_x_peak_speed: float = 6.0
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
	blend_time_by_action = {
		Leg.Act.run: 0.3,
	}
	

func _calculate_anim_effective_duration(actual_anim: AnimationData) -> float:
	var _anim_start := actual_anim.get_marker_time_by_name(Marker.Name_.FROM_RUN, 0.0)
	var _anim_end := actual_anim.get_marker_time_by_name(Marker.Name_.TO_RUN, 1.0)
	start_time_offset = _anim_start # NOTE: side effect
	return _anim_end - _anim_start


func on_enter_action(input_: InputPackage) -> void:
	# DIRECTION
	var _strafe_dir := input_.detect_strafe_dir()
	curr_dodge_dir.set_direction_from_strafe_dir(_strafe_dir)

	# INTERPOLATOR
	var _inherited_speed := pm().get_curr_velocity_len()
	var _actual_anim := anim_container.get_by_name(curr_dodge_dir.get_curr_anim_id())
	var _anim_effective_dur := _calculate_anim_effective_duration(_actual_anim)
	speed_x_interpolator.initialise(_inherited_speed, 2, dodge_x_peak_speed, dodge_x_curve, _anim_effective_dur + dodge_x_dur_correction)
	
	__log_action_ent("curr_dodge_dir", curr_dodge_dir.pp_curr_dir(),
		"from strafe", StrafeDir.name_(_strafe_dir),
		"calc_anim_dur", _anim_effective_dur,
	)


func update(input_: InputPackage, delta: float) -> void:
	if player_sm.area_awareness.is_camera_locked():
		pm().look_at_target(delta)

	var current_speed := speed_x_interpolator.update(delta)
	
	var _curr_world_vector = curr_dodge_dir.current_world_vector(get_player().basis)
	get_player().velocity = _curr_world_vector * current_speed

	if tracks_input_vector():
		pm().rotate_with_input_vector(input_, delta)


func animate(): # ▶️
	blend_time = 0.1
	
	anim = anim_container.get_by_name(curr_dodge_dir.get_curr_anim_id())
	
	set_anim_to_play()
