extends PlayerAction


@export var flying_x_curve: Curve # bell-curve which ends a little earlier

var ANIM_R := A.fall_stand_up.thrown_r_rm
var ANIM_L := A.fall_stand_up.thrown_l_rm
var ANIM_R_small := A.fall_stand_up.thrown_r_small_rm
var ANIM_L_small := A.fall_stand_up.thrown_l_small_rm

const LEFT = "LEFT"
const RIGHT = "RIGHT"
const BACK = "BACK"


var curr_dir: String

var PEAK_SPEED: float = 6.5
var END_SPEED: float = 0.0

var speed_x_interpolator := HillInterpolator.new()


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 0.1
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0))

func _locked_and_not_sprint() -> bool:
	if player_sm.area_awareness.is_camera_locked() and not PREV_ACTION == Leg.Act.sprint:
		return true
	return false

func _decide_on_mode_on_enter():
	var _reason: String = ""
	var hit = player_sm.combat.get_last_processed_hit()
	curr_dir = RIGHT
	if not hit:
		_reason = "no hit data found => default"
		__log_decide_on_mode(_reason)
		return
		
	var _attack_dir := ReactUtils.get_attack_dir_by_enemy_attack(hit.anim_id)
	match _attack_dir:
		AttackDirection.Dir.LEFT:
			_reason = "_attack_dir L"
			curr_dir = RIGHT if _locked_and_not_sprint() else LEFT
		AttackDirection.Dir.RIGHT:
			_reason = "_attack_dir R"
			curr_dir = LEFT if _locked_and_not_sprint() else RIGHT
		_:
			_reason = "_attack_dir is not L/R"
			curr_dir = BACK if _locked_and_not_sprint() else RIGHT


func _calculate_interpolator_duration(actual_anim: AnimationData) -> float:
	var _start := actual_anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0)
	var _end := actual_anim.get_marker_time_by_name(MarkerName.LAND_START, 1.0)
	var _dur = (_end - _start) / anim.speed_scale + 0.1 # + 0.1 to be safe
	__log_ent("calculated _interpolator_dur", _dur, "using markers with time", _start, _end)
	return _dur


func on_enter_action(input_: InputPackage):
	_decide_on_mode_on_enter()
	PEAK_SPEED = 6.5
	var extra_start_speed := 0.0
	# curr_dir = BACK
	match curr_dir:
		RIGHT:
			anim = anim_container.get_by_anim_id(ra.spick_random(ANIM_R, ANIM_R_small))
			PEAK_SPEED = 9.5
			extra_start_speed = 3.0
		LEFT:
			anim = anim_container.get_by_anim_id(ra.spick_random(ANIM_L, ANIM_L_small))
			PEAK_SPEED = 8.5
			extra_start_speed = 2.0
		BACK:
			anim = anim_container.get_by_anim_id(ra.spick_random(ANIM_R, ANIM_R_small)) # right anim
			PEAK_SPEED = 8.5
			extra_start_speed = 0.0
		_:
			anim = anim_container.get_by_anim_id(ra.spick_random(ANIM_R, ANIM_R_small))
			PEAK_SPEED = 9.5
			extra_start_speed = 3.0


	var _inherited_speed := pm().get_curr_velocity_len()
	var _interpolator_dur := _calculate_interpolator_duration(anim)

	
	speed_x_interpolator.initialise(_inherited_speed + extra_start_speed, END_SPEED, PEAK_SPEED, flying_x_curve, _interpolator_dur)


func on_exit_action():
	animator_manager.reset_global_speed_scale()
	speed_x_interpolator.reset()


func update(input_: InputPackage, delta: float) -> void:
	# if player_sm.area_awareness.is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		# pm().look_at_target(delta)
	if before_marker(MarkerName.LAND_START):
		var current_speed := speed_x_interpolator.update(delta)
		__log_upd(speed_x_interpolator._get_progress(), current_speed)
		
		var _curr_world_vector := _get_current_world_vector(get_player().basis)
		pm().set_velocity(_curr_world_vector * current_speed)
	else:
		# If LAND_START placed where root naturally stops, it will play well
		pm().move_with_root(delta)
		__log_upd(get_player().velocity)

	# later
	# if tracks_input_vector():
		# pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))


func _get_current_world_vector(player_basis: Basis) -> Vector3:
	match curr_dir:
		RIGHT:
			return -player_basis.x
		LEFT:
			return player_basis.x
		BACK:
			return -player_basis.z
	return Vector3.ZERO


func __log_decide_on_mode(_reason: String):
	__log_ent(_reason, "-> set curr mode", curr_dir)
