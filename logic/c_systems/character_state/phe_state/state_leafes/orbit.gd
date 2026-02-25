extends BasePHELeaf

@export var dir_change_curve: Curve # for opposite direction changes
@export var accel_from_idle_curve: Curve

const OPP_DIR_CHANGE_DURATION: float = 1.2
var accel_from_inherited: float = 0.6
var accel_from_idle: float = 0.5
var ONE_DIR_COMMIT: float = 9.0

var SPEED_R: float = 2.2 + 0.1
var SPEED_L: float = 2.1 + 0.1
# todo: may be rewrite with ActionModeSwitcher
var curr_direction: DualDirection

var opposite_dir_change := StrafeDirChange.new()
var speed_from_inherited := FloatLinearInterpolator.new()
var speed_mult_from_idle := EaseCurveInterpolator.new()
var angular_accel := FloatLinearInterpolator.new()
var _one_dir_timer: SimpleTimer = SimpleTimer.new()

var _resettable := [
	opposite_dir_change,
	speed_from_inherited,
	speed_mult_from_idle,
	angular_accel,
	_one_dir_timer
]


func initialise() -> void:
	curr_direction = DualDirection.new(SPEED_R, SPEED_L, PHEA.strafe.strafe_right, PHEA.strafe.strafe_left)
	opposite_dir_change.initialise(dir_change_curve, OPP_DIR_CHANGE_DURATION, 2)
	default_sp.SPEED = 5.0
	default_sp.TURN_SPEED = 3.2
	default_sp.ANGULAR_SPEED = 6

	blend_time.set_specific(0.35)
	blend_time.set_by_prev_action({
		PHES.Leaf.scare_off: 0.34,
		PHES.Leaf.combat_idle: 0.3,
		PHES.Leaf.club_part_1: 0.3,
		PHES.Leaf.club_part_2: 0.4,
		PHES.Leaf.club_part_3_4: 0.3,
	})


func _get_curr_direction_speed() -> float:
	return curr_direction.get_curr_speed() + fvalue_angry(0.0, 2.0)


func on_enter_state() -> void:
	tu.reset_all(_resettable)
	_choose_initial_direction()

	var _inherited_speed := e_movement.get_curr_velocity_len()
	if __LOG_B(): __log_ent("_inherited_speed", _inherited_speed, "would be _inherited_speed -> ", _get_curr_direction_speed())
	_inherited_speed = clampf(_inherited_speed, _inherited_speed, 2.0)
	if __LOG_B(): __log_ent("_inherited_speed clamped", _inherited_speed)
	speed_from_inherited.initialise(_inherited_speed, _get_curr_direction_speed(), accel_from_inherited + 1.0)
	angular_accel.initialise(0.4, default_sp.ANGULAR_SPEED, 0.8)
	match PREV_LEAF:
		PHES.Leaf.combat_idle:
			speed_mult_from_idle.initialise(accel_from_idle_curve, accel_from_idle + 1.0)


func on_exit_state() -> void:
	tu.reset_all(_resettable)
	get_animator_manager().reset_global_speed_scale()


func update(delta: float) -> void:
	var SPEED_MULT := 1.0
	var CURR_SPEED := _get_curr_direction_speed()
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED

	
	SPEED_MULT *= opposite_dir_change.speed_dip_update(delta)
	CURR_ANGULAR_SPEED = angular_accel.update(delta)


	match PREV_LEAF:
		PHES.Leaf.combat_idle:
			SPEED_MULT *= speed_mult_from_idle.update(delta)
		_:
			CURR_SPEED = speed_from_inherited.update(delta)


	var _sp_config := SpeedConfig.new(default_sp, SPEED_MULT, CURR_SPEED, CURR_ANGULAR_SPEED)
	
	e_movement.rotate_towards_player(delta, _sp_config)
	e_movement.orbit(-curr_direction.get_curr_dir_int(), _sp_config) # note the minus

	opposite_dir_change.async_change_update(delta)

	if _one_dir_timer.update(delta) and opposite_dir_change.cooldown.update(delta):
		if __LOG_B(): __log_upd("wanna change strafe dir, one dir timer time", _one_dir_timer.get_elapsed())
		opposite_dir_change.speed_dip_init()
		opposite_dir_change.async_change_init(_change_dir.bind())
		opposite_dir_change.cooldown.reset()
		if __LOG_B(): __log_upd("OPPOSITE dir change and dip triggered")

	get_animator_manager().set_global_speed_scale(maxf(SPEED_MULT + fvalue_angry(0.0, 0.3), 0.5))


func _set_up_commit_timer():
	var _one_dir_commitment := ra.frange(ONE_DIR_COMMIT - 4, ONE_DIR_COMMIT + 4)
	_one_dir_timer.initialise(_one_dir_commitment)


func _choose_initial_direction(to_opposite: bool = false):
	match PREV_LEAF:
		PHES.Leaf.dodge_R:
			curr_direction.set_direction(DualDirection.Dir.PRIMARY)
		PHES.Leaf.dodge_L:
			curr_direction.set_direction(DualDirection.Dir.SECONDARY)

		_:
			curr_direction.set_direction(DualDirection.Dir.PRIMARY if ra.coinflip() else DualDirection.Dir.SECONDARY)

	anim = anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	_set_up_commit_timer()
	if __LOG_B(): __log_ent("chosen initial direction", curr_direction)


func _change_dir() -> void:
	curr_direction.flip_direction()
	if __LOG_B(): __log_upd("_change_dir to", curr_direction.get_curr_dir())
	_set_up_commit_timer()
	_switch_animation()


var sync_loco_anim_correction: float = 0.18
var __dev_add: float = 0.0


func _switch_animation() -> void:
	var next_anim := anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	var curr_anim := anim

	if next_anim.anim_id == curr_anim.anim_id:
		if __LOG_B(): print_.dev("", "_switch_animation same anim, won't switch")
		return
		

	var _custom_blend_time := blend_time.calculate_actual(PREV_LEAF)
	var _custom_start_time_offset := start_time_offset.calculate_actual(PREV_LEAF)

	if curr_anim.anim_id in curr_direction.get_all_anim_ids():
		var r := sync_with_curr_loco_anim(next_anim, sync_loco_anim_correction)
		if r != -1:
			_custom_start_time_offset = r
		_custom_blend_time = 0.2
	else:
		_custom_blend_time = 0.3
		__log_warn(state_name + " _switch_animation but not from strafe anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!

	set_anim_to_play(_custom_blend_time, _custom_start_time_offset)
