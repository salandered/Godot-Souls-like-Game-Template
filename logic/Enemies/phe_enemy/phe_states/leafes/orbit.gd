extends BasePHELeaf

@export var dir_change_curve: Curve # for opposite direction changes
@export var accel_from_idle_curve: Curve

const OPP_DIR_CHANGE_DURATION: float = 1.2
var accel_from_inherited: float = 0.6
var accel_from_idle: float = 0.5
var ONE_DIR_COMMIT: float = 9.0

var SPEED_R: float = 2.2
var SPEED_L: float = 2.1
var curr_direction: DualDirection

var opposite_dir_change := StrafeDirChange.new()
var speed_from_inherited := FloatLinearInterpolator.new()
var speed_mult_from_idle := EaseCurveInterpolator.new()
var angular_sp := FloatLinearInterpolator.new()
var _one_dir_timer: DelayTimer = DelayTimer.new()

var _resettable = [
	opposite_dir_change,
	speed_from_inherited,
	speed_mult_from_idle,
	angular_sp,
	_one_dir_timer
]


func initialise() -> void:
	curr_direction = DualDirection.new(SPEED_R, SPEED_L, PHEA.loco.strafe_right, PHEA.loco.strafe_left)
	opposite_dir_change.initialise(dir_change_curve, OPP_DIR_CHANGE_DURATION, 2)
	default_sp.SPEED = 5.0
	default_sp.TURN_SPEED = 3.2
	default_sp.ANGULAR_SPEED = 6

	blend_time.set_by_prev_action({
		PHEState.Leaf.scare_off: 0.34,
		PHEState.Leaf.combat_idle: 0.3,
		PHEState.Leaf.club_part_1: 0.3,
		PHEState.Leaf.club_part_2: 0.4,
		PHEState.Leaf.club_part_3_4: 0.3,
	})


func on_enter_state():
	u.reset_all(_resettable)
	_choose_initial_direction()

	var _inherited_speed := e_movement.get_curr_velocity_len()
	__log_ent("_inherited_speed", _inherited_speed, "would be _inherited_speed -> ", curr_direction.get_curr_speed())
	speed_from_inherited.initialise(_inherited_speed, curr_direction.get_curr_speed(), accel_from_inherited)
	angular_sp.initialise(1, default_sp.ANGULAR_SPEED, 0.8)
	match PREV_LEAF:
		PHEState.Leaf.combat_idle:
			speed_mult_from_idle.initialise(accel_from_idle_curve, accel_from_idle)


func on_exit_state():
	u.reset_all(_resettable)
	get_animator_manager().reset_global_speed_scale()


func update(delta: float):
	var SPEED_MULT := 1.0
	var CURR_SPEED = curr_direction.get_curr_speed()
	var CURR_ANGULAR_SPEED := default_sp.ANGULAR_SPEED

	CURR_SPEED = speed_from_inherited.update(delta)
	SPEED_MULT *= opposite_dir_change.speed_dip_update(delta)
	CURR_ANGULAR_SPEED = angular_sp.update(delta)


	match PREV_LEAF:
		PHEState.Leaf.combat_idle:
			SPEED_MULT *= speed_mult_from_idle.update(delta)


	var _sp_config := SpeedConfig.new(default_sp, SPEED_MULT, CURR_SPEED, CURR_ANGULAR_SPEED)
	
	e_movement.rotate_towards_player(delta, _sp_config)
	e_movement.orbit(-curr_direction.get_curr_dir_int(), _sp_config) # note the minus

	opposite_dir_change.async_change_update(delta)

	if _one_dir_timer.update(delta) and opposite_dir_change.cooldown.update(delta):
		__log_upd("wanna change strafe dir, one dir timer time", _one_dir_timer.get_elapsed())
		opposite_dir_change.speed_dip_init()
		opposite_dir_change.async_change_init(_change_dir.bind())
		opposite_dir_change.cooldown.reset()
		__log_upd("OPPOSITE dir change and dip triggered")

	get_animator_manager().set_global_speed_scale(SPEED_MULT)


func _set_up_commit_timer():
	var _one_dir_commitment = ra.float_range(ONE_DIR_COMMIT - 4, ONE_DIR_COMMIT + 4)
	_one_dir_timer.initialise(_one_dir_commitment)


func _choose_initial_direction(to_opposite: bool = false):
	curr_direction.set_direction(DualDirection.Dir.PRIMARY if ra.coinflip() else DualDirection.Dir.SECONDARY)
	anim = me.anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	_set_up_commit_timer()


func _change_dir():
	curr_direction.flip_direction()
	__log_upd("_change_dir to", curr_direction.get_curr_dir())
	_set_up_commit_timer()
	_switch_animation()


func sync_with_curr_loco_anim(next_anim: AnimationData, next_anim_correction: float = 0.0) -> float:
	var curr_anim_progress := get_animator_manager().get_current_anim_effective_time_spent()
	var result_offset = AnimHelpers.sync_with_loco_anim(anim, curr_anim_progress, next_anim, next_anim_correction)
	return result_offset


var sync_loco_anim_correction: float = 0.18
var __dev_add: float = 0.0


func _switch_animation():
	var next_anim := anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	var curr_anim := anim

	var _custom_blend_time = blend_time.calculate_actual(PREV_LEAF)
	var _custom_start_time_offset = start_time_offset.calculate_actual(PREV_LEAF)

	if next_anim.anim_id == curr_anim.anim_id:
		print_.dev("", "_switch_animation same anim, won't switch")
		return

	if curr_anim.anim_id in curr_direction.get_all_anim_ids():
		var r := sync_with_curr_loco_anim(next_anim, sync_loco_anim_correction)
		if r != -1:
			_custom_start_time_offset = r
		# for perfect smoothness it should be equal to timer cooldowns
		_custom_blend_time = 0.2
	else:
		_custom_blend_time = 0.3
		print_.warn(state_name + " _switch_animation but not from strafe anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!

	set_anim_to_play(_custom_blend_time, _custom_start_time_offset)
