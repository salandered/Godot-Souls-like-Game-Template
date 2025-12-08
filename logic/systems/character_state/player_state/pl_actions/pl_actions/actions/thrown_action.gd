extends PlayerAction


@export var flying_x_curve: Curve # bell-curve which ends a little earlier

var ANIM_L := A.fall_stand_up.thrown_l_rm
var ANIM_R := A.fall_stand_up.thrown_r_rm
var ANIM_L_LOW := A.fall_stand_up.thrown_l_small_rm
var ANIM_R_LOW := A.fall_stand_up.thrown_r_small_rm

const LEFT = "LEFT"
const RIGHT = "RIGHT"
const BACK = "BACK"

class ThrowPack:
	var anim_id: String
	var peak_speed: float
	var end_speed: float
	var extra_start_speed: float
	var direction: String
	func _init(anim_id_: String, peak_speed_: float, end_speed_: float, extra_start_speed_: float, direction_: String) -> void:
		self.anim_id = anim_id_
		self.peak_speed = peak_speed_
		self.end_speed = end_speed_
		self.extra_start_speed = extra_start_speed_
		self.direction = direction_
	func _to_string() -> String:
		return "ThrowPack(dir %s, anim %s, peak/end/extra %.1f/%.1f/%.1f)" % [direction, pp.anim_n(anim_id), peak_speed, end_speed, extra_start_speed]


var DEF_PEAK_SP: float = 8.5
var DEF_END_SP: float = 0.0
var DEF_EXTRA_START_SP: float = 0.0

var left_throw_pack := ThrowPack.new(ANIM_L, DEF_PEAK_SP + 2.0, DEF_END_SP, DEF_EXTRA_START_SP + 2.0, LEFT)
var right_throw_pack := ThrowPack.new(ANIM_R, DEF_PEAK_SP + 2.0, DEF_END_SP, DEF_EXTRA_START_SP + 2.0, RIGHT)
var back_throw_pack := ThrowPack.new(ANIM_R, DEF_PEAK_SP + 2.0, DEF_END_SP, DEF_EXTRA_START_SP + 2.0, BACK) # uses right anim
var left_low_throw_pack := ThrowPack.new(ANIM_L_LOW, DEF_PEAK_SP, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.5, LEFT)
var right_low_throw_pack := ThrowPack.new(ANIM_R_LOW, DEF_PEAK_SP, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.5, RIGHT)
var back_low_throw_pack := ThrowPack.new(ANIM_R_LOW, DEF_PEAK_SP, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.5, BACK)

var curr_throw: ThrowPack

var speed_x_interpolator := HillInterpolator.new()


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 0.1
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0))

func _locked_and_not_sprint() -> bool:
	# todoL use actual angle between pl and enemy
	if player_sm.area_awareness.is_camera_locked(): # and not PREV_ACTION == Leg.Act.sprint:
		return true
	return false

func _decide_on_mode_on_enter():
	var _reason: String = ""
	curr_throw = right_throw_pack
	var hit = player_sm.combat.get_last_processed_hit()
	if not hit:
		_reason = "no hit data found => default"
		__log_decide_on_mode(_reason)
		return
		
	var _attack_dir := ReactionOnHit.get_attack_dir_by_enemy_attack(hit.anim_id)
	match _attack_dir:
		AttackDirection.Dir.LEFT:
			_reason = "_attack_dir L"
			curr_throw = right_throw_pack if _locked_and_not_sprint() else left_throw_pack
		AttackDirection.Dir.RIGHT:
			_reason = "_attack_dir R"
			curr_throw = left_throw_pack if _locked_and_not_sprint() else right_throw_pack
		AttackDirection.Dir.DOWN:
			_reason = "_attack_dir DOwn"
			curr_throw = back_throw_pack if _locked_and_not_sprint() else right_throw_pack
		_:
			_reason = "_attack_dir is not L/R"
			curr_throw = back_throw_pack if _locked_and_not_sprint() else right_throw_pack
	
	if hit.damage <= 25:
		_reason += " | hit.damage <= 20 => low version"
		match curr_throw.direction:
			LEFT:
				curr_throw = left_low_throw_pack
			RIGHT:
				curr_throw = right_low_throw_pack
			BACK:
				curr_throw = back_low_throw_pack


	__log_decide_on_mode(_reason)


func _calculate_interpolator_duration(actual_anim: AnimationData) -> float:
	var _start := actual_anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0)
	var _end := actual_anim.get_marker_time_by_name(MarkerName.JUMP.LAND_START, 1.0)
	var _dur = (_end - _start) / anim.speed_scale + 0.1 # + 0.1 to be safe
	__log_ent("calculated _interpolator_dur", _dur, "using markers with time", _start, _end)
	return _dur


func on_enter_action(input_: InputPackage):
	_decide_on_mode_on_enter()
	# curr_throw = back_low_throw_pack # DEV WARNING
	anim = anim_container.get_by_anim_id(curr_throw.anim_id)
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0))

	var _inherited_speed := pm().get_curr_velocity_len()
	var _interpolator_dur := _calculate_interpolator_duration(anim)
	
	speed_x_interpolator.initialise(
		_inherited_speed + curr_throw.extra_start_speed,
		curr_throw.end_speed,
		curr_throw.peak_speed,
		flying_x_curve,
		_interpolator_dur)


func on_exit_action():
	speed_x_interpolator.reset()


func update(input_: InputPackage, delta: float) -> void:
	if player_sm.area_awareness.is_camera_locked() and PREV_ACTION != Leg.Act.sprint:
		pm().look_at_target(delta)
	if before_marker(MarkerName.JUMP.LAND_START):
		var current_speed := speed_x_interpolator.update(delta)
		# __log_upd(speed_x_interpolator._get_progress(), current_speed)
		
		var _curr_world_vector := _get_current_world_vector(get_player().basis)
		pm().set_velocity(_curr_world_vector * current_speed)
	else:
		# If LAND_START placed where root naturally stops, it will play well
		pm().move_with_root(delta)
		# __log_upd(get_player().velocity)

	# later
	# if tracks_input_vector():
		# pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))


func _get_current_world_vector(player_basis: Basis) -> Vector3:
	match curr_throw.direction:
		RIGHT:
			return -player_basis.x
		LEFT:
			return player_basis.x
		BACK:
			return -player_basis.z
	return Vector3.ZERO


func __log_decide_on_mode(_reason: String):
	__log_ent(_reason, "-> set curr mode", curr_throw)
