extends LegsAction

@export var accel_from_idle_curve: Curve
@export var dir_change_curve: Curve # for opposite direction changes
@export var slght_dir_change_curve: Curve # for slight direction changes


const ACCEL_FROM_IDLE_TIME: float = 0.31

const OPP_DIR_CHANGE_DURATION: float = 0.14
const SLIGHT_DIR_CHANGE_DURATION: float = 0.08
const SLIGHTEST_DIR_CHANGE_DURATION: float = 0.02


## TODO: this begs the question, do we need explicit idle action in strafe behavior at all?
## 		 since adding NEUTRAL direction, here in strafe there is lot of logic for idle.
const ANIM_IDLE := A.loco.idle

const ANIM_L := A.strafe.strafe_L
const ANIM_R := A.strafe.strafe_R
const SPEED_R: float = 2.9 + 0.4
const SPEED_L: float = 2.8 + 0.4

const ANIM_F := A.strafe.combat_run_f
const ANIM_B := A.strafe.combat_run_b
const SPEED_F: float = 3.1 + 0.4
const SPEED_B: float = 2.4 + 0.4

var curr_direction: StrafeDirection

var speed_from_inherited := FloatLinearInterpolator.new()
var speed_mult_from_idle := EaseCurveInterpolator.new()
var angular_sp_from_idle := FloatLinearInterpolator.new()
var opposite_dir_change := StrafeDirChange.new()
var slight_dir_change := StrafeDirChange.new()
# var slightest_dir_change := StrafeDirChange.new()

var TURN_THRESHOLD_DEG: float = 15
var DECELERATION_FRICTION: float = 8.0

var SPEED_BOOST: float = 0.0

var _resettable := [
	speed_from_inherited,
	speed_mult_from_idle,
	angular_sp_from_idle,
	opposite_dir_change,
	slight_dir_change,
	# slightest_dir_change,
]

var _changers_cooldown := [
	opposite_dir_change.cooldown,
	slight_dir_change.cooldown,
	# slightest_dir_change.cooldown
]

func initialise() -> void:
	default_sp.ANGULAR_SPEED = 8
	curr_direction = StrafeDirection.new(SPEED_R, ANIM_R, SPEED_L, ANIM_L, SPEED_F, ANIM_F, SPEED_B, ANIM_B, ANIM_IDLE)
	opposite_dir_change.initialise(dir_change_curve, OPP_DIR_CHANGE_DURATION, 2)
	slight_dir_change.initialise(slght_dir_change_curve, SLIGHT_DIR_CHANGE_DURATION, 2)
	# slightest_dir_change.initialise(slght_dir_change_curve, SLIGHTEST_DIR_CHANGE_DURATION, 2)

	var turn_180_blend_time := calculate_blend_time_from_prev_anim_marker(Leg.Act.turn_180, MarkerName.TURN_180_APEX, 0.25)
	blend_time.set_by_prev_action({
			Leg.Act.sprint: 0.3,
			Leg.Act.idle: 0.3, # 0.3 works good
			Leg.Act.turn_180: turn_180_blend_time,
			PS.Act.landing_sprint: 0.4,
			PS.Act.dodge: 0.3
	})

	GlobalSignal.player_speed_increase.connect_(_on_speed_increase)
	
func _inherit_dodge_speed_if_same_direction():
	# todo: should not use animations but dodge dir
	var _inherited_speed := pm().get_curr_velocity_len()
	## animator manager treats prev anim as curr because we are in on_enter_action
	var prev_anim_id := get_animator_manager().get_curr_anim().anim_id
	var curr_dir := curr_direction.get_curr_dir()
	var _inherit_speed: bool = false
	if prev_anim_id == A.dodge.dodge_R and curr_dir in Direction.get_right_group():
		_inherit_speed = true
	elif prev_anim_id == A.dodge.dodge_L and curr_dir in Direction.get_left_group():
		_inherit_speed = true
	elif prev_anim_id == A.dodge.dodge_F and curr_dir in Direction.get_forward_group():
		_inherit_speed = true
	elif prev_anim_id == A.dodge.dodge_B and curr_dir in Direction.get_backward_group():
		_inherit_speed = true

	if _inherit_speed:
		speed_from_inherited.initialise(_inherited_speed, curr_direction.get_curr_speed(), 0.3)
		speed_mult_from_idle.initialise(accel_from_idle_curve, 0.0)

	else:
		speed_from_inherited.initialise(curr_direction.get_curr_speed(), curr_direction.get_curr_speed(), 0.0)
		speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)

	
func on_enter_action(input_: InputPackage) -> void:
	tu.reset_all(_resettable)

	var _dir := input_.detect_strafe_dir()
	print_preset.lsm_action_strafe(pp.on_ent, "detected strafe dir: " + Direction.name_(_dir))
	curr_direction.set_direction(_dir)
	

	match PREV_ACTION:
		_ when PREV_ACTION in IDLE_LIKE_ACTIONS:
		# Leg.Act.idle:
			default_sp.ANGULAR_SPEED = 7
			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)
			angular_sp_from_idle.initialise(default_sp.ANGULAR_SPEED / 2, default_sp.ANGULAR_SPEED, 0.4)
			TURN_THRESHOLD_DEG = 181
		
		Leg.Act.turn_180, Leg.Act.fast_turn_180:
			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)
		PS.Act.dodge:
			default_sp.ANGULAR_SPEED = 8
			_inherit_dodge_speed_if_same_direction()
			TURN_THRESHOLD_DEG = 15

		Leg.Act.sprint:
			default_sp.ANGULAR_SPEED = 8
			TURN_THRESHOLD_DEG = 15
		_:
			TURN_THRESHOLD_DEG = 15

func on_exit_action() -> void:
	get_animator_manager().reset_global_speed_scale()
	tu.reset_all(_resettable)


func update(input_: InputPackage, delta: float) -> void:
	var CURR_SPEED := curr_direction.get_curr_speed()
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED
	var SPEED_MULT := 1.0

	match PREV_ACTION:
		_ when PREV_ACTION in IDLE_LIKE_ACTIONS:
			SPEED_MULT = speed_mult_from_idle.update(delta)
			CURR_ANGULAR_SPEED = angular_sp_from_idle.update(delta)
		Leg.Act.turn_180, Leg.Act.fast_turn_180:
			SPEED_MULT = speed_mult_from_idle.update(delta)
		PS.Act.dodge:
			SPEED_MULT = speed_mult_from_idle.update(delta)
			CURR_SPEED = speed_from_inherited.update(delta)
			

	var _prev_sp_mult := SPEED_MULT
	SPEED_MULT *= opposite_dir_change.speed_dip_update(delta)
	SPEED_MULT *= slight_dir_change.speed_dip_update(delta)
	# SPEED_MULT *= slightest_dir_change.speed_dip_update(delta)
	

	CURR_SPEED = player_sm.apply_hit_influence(CURR_SPEED)
	var _sp_config := SpeedConfig.new(
		default_sp,
		SPEED_MULT,
		CURR_SPEED + SPEED_BOOST,
		CURR_ANGULAR_SPEED
		)

	pm().look_at_target(delta, _sp_config)

	var remaining_angle_to_target := absf(pm().get_signed_angle_pl_target())

	if remaining_angle_to_target < deg_to_rad(TURN_THRESHOLD_DEG):
		if curr_direction.is_pure_vertical():
			pm().move_forward_or_back(curr_direction.get_dir_int(), delta, _sp_config)
		else:
			pm().move_strafe_with_forward(input_, -curr_direction.get_dir_int(), delta, _sp_config) # note the minus
	else:
		# pm().set_velocity(Vector3.ZERO)
		pm().apply_friction_xz(delta, DECELERATION_FRICTION)

	opposite_dir_change.async_change_update(delta)
	slight_dir_change.async_change_update(delta)

	var new_dir := input_.detect_strafe_dir()
	if new_dir != curr_direction.get_curr_dir():
		print_preset.lsm_action_strafe(pp.on_upd, pp.s("detected new dir", curr_direction.pp_curr_dir(), "=>", Direction.name_(new_dir)))
	
	match curr_direction.would_be_change_of_type(new_dir):
		DirPairs.ChangeType.OPPOSITE:
			if opposite_dir_change.cooldown.update(delta):
				opposite_dir_change.speed_dip_init()
				opposite_dir_change.async_change_init(_change_dir.bind(true, new_dir, true))
				
				tu.reset_all(_changers_cooldown)
				print_preset.lsm_action_strafe("", "~~ OPPOSITE dir change and dip triggered")

		DirPairs.ChangeType.SLIGHT:
			if slight_dir_change.cooldown.update(delta):
				slight_dir_change.speed_dip_init()
				slight_dir_change.async_change_init(_change_dir.bind(false, new_dir, true))
				
				tu.reset_all(_changers_cooldown)
				print_preset.lsm_action_strafe("", "~~ SLIGHT dir change and dip triggered")
		
		DirPairs.ChangeType.SLIGHTEST:
			_change_dir(false, new_dir)
			
			tu.reset_all(_changers_cooldown)
			print_preset.lsm_action_strafe("", "~~ SLIGHTEST dir change")

		DirPairs.ChangeType.SAME:
			tu.reset_all(_changers_cooldown)

	get_animator_manager().set_global_speed_scale(pm().get_curr_velocity_len() / CURR_SPEED)
	# get_animator_manager().set_global_speed_scale(SPEED_MULT)

func _change_dir(is_opposite_change: bool, new_dir: Direction.Dir, from_callback: bool = false):
	# ?? question: is it ok that we re evalutaing dir. bake into callback?
	# upd: answer is probably no
	var actual_new_dir := InputManager._current_input.detect_strafe_dir()
	curr_direction.set_direction(actual_new_dir)
	print_preset.lsm_action_strafe("", pp.s(
		"from_callback is", from_callback,
		"| _change_dir to", curr_direction.pp_curr_dir(),
		"while initial was", Direction.name_(new_dir)))
	_switch_animation(is_opposite_change)


func animate(): # ▶️
	var custom_blend_time := blend_time.calculate_actual(PREV_ACTION)
	match PREV_ACTION:
		Leg.Act.sprint:
			if curr_direction.get_curr_dir() in Direction.get_right_group():
				custom_blend_time = 0.15
	anim = anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	set_anim_to_play(custom_blend_time)


var sync_loco_anim_correction: float = 0.18
var __dev_add: float = 0.0


func _switch_animation(is_opposite_change: bool):
	var next_anim := anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	var curr_anim := anim

	var _custom_blend_time := blend_time.calculate_actual(PREV_ACTION)
	var _custom_start_time_offset := start_time_offset.calculate_actual(PREV_ACTION)

	
	if next_anim.anim_id == curr_anim.anim_id:
		print_preset.lsm_action_strafe("", "_switch_animation same anim, won't switch")
		return

	if _one_anim_is_idle(curr_anim, next_anim):
		_custom_blend_time = 0.25
	elif curr_anim.anim_id in curr_direction.get_all_anim_ids():
		# if curr_anim.anim_id == A.strafe.combat_run_b and next_anim.anim_id in [A.strafe.strafe_L, A.strafe.strafe_R]:
		# 	sync_loco_anim_correction = 0.0 + __dev_add
		# 	__log_action(em.pin, em.mark_alt)
		var r := sync_with_curr_loco_anim(next_anim, sync_loco_anim_correction)
		if r != -1:
			_custom_start_time_offset = r
		# for perfect smoothness it should be equal to timer cooldowns
		_custom_blend_time = 0.24 if is_opposite_change else 0.3
	else:
		_custom_blend_time = 0.3
		__log_warn(action_name + "_switch_animation but not from strafe anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!

	set_anim_to_play(_custom_blend_time, _custom_start_time_offset)


func _one_anim_is_idle(curr_anim: AnimationData, next_anim: AnimationData) -> bool:
	return curr_anim.anim_id == ANIM_IDLE or next_anim.anim_id == ANIM_IDLE


func _on_speed_increase(payload: Dictionary[StringName, Variant]) -> void:
	# __log_("_on_speed_increase", "triggered")
	var value = payload.get(SPS.amount_field)
	if value and (value is float or value is int):
		SPEED_BOOST += value

# func _input(event):
# 	TURN_THRESHOLD_DEG = InputUtils._dev_change_t34_param(event, TURN_THRESHOLD_DEG, "TURN_THRESHOLD_DEG", 15)
