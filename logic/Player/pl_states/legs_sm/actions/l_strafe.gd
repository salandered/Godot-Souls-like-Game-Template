extends LegsAction

@export var accel_from_idle_curve: Curve
@export var dir_change_curve: Curve # for opposite direction changes
@export var slght_dir_change_curve: Curve # for slight direction changes


var speed_mult_from_idle := EaseCurveInterpolator.new()

const ACCEL_FROM_IDLE_TIME: float = 0.21

const OPP_DIR_CHANGE_DURATION: float = 0.16
const SLIGHT_DIR_CHANGE_DURATION: float = 0.08
const SLIGHTEST_DIR_CHANGE_DURATION: float = 0.02


## TODO: this begs the question, do we need explicit idle action in strafe behavior at all?
## 		 since adding NEUTRAL direction, here in strafe there is lot of logic for idle.
const ANIM_IDLE: String = A.move.idle

const ANIM_L: String = A.strafe.strafe_L
const ANIM_R: String = A.strafe.strafe_R
const SPEED_R: float = 2.9
const SPEED_L: float = 2.8

const ANIM_F: String = A.strafe.combat_run_f
const ANIM_B: String = A.strafe.combat_run_b
const SPEED_F: float = 3.1
const SPEED_B: float = 2.4

var curr_direction: StrafeDirection

var opposite_dir_change := StrafeDirChange.new()
var slight_dir_change := StrafeDirChange.new()
var slightest_dir_change := StrafeDirChange.new()

var _resettable = [
	speed_mult_from_idle,
	opposite_dir_change,
	slight_dir_change,
	slightest_dir_change
]

var _changers_cooldown = [
	opposite_dir_change.cooldown,
	slight_dir_change.cooldown,
	slightest_dir_change.cooldown
]

func initialise():
	default_sp.ANGULAR_SPEED = 7
	curr_direction = StrafeDirection.new(SPEED_R, ANIM_R, SPEED_L, ANIM_L, SPEED_F, ANIM_F, SPEED_B, ANIM_B, ANIM_IDLE)
	opposite_dir_change.initialise(dir_change_curve, OPP_DIR_CHANGE_DURATION, 2)
	slight_dir_change.initialise(slght_dir_change_curve, SLIGHT_DIR_CHANGE_DURATION, 2)
	slightest_dir_change.initialise(slght_dir_change_curve, SLIGHTEST_DIR_CHANGE_DURATION, 2)

	blend_time.set_by_prev_action({
			Leg.Act.sprint: 0.3
	})


func on_enter_action(input_: InputPackage) -> void:
	u.reset_all(_resettable)

	var _dir := input_.detect_strafe_dir()
	print_.lsm_action_strafe(pp.on_ent, "detected strafe dir: " + Direction.name_(_dir))
	curr_direction.set_direction(_dir)
	
	match PREV_ACTION:
		Leg.Act.idle:
			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)

		# Leg.Act.sprint:
			# if curr_direction.get_curr_dir() == Direction.Dir.RIGHT:
				# default_sp.ANGULAR_SPEED = 8

func on_exit_action() -> void:
	get_animator_manager().reset_global_speed_scale()
	u.reset_all(_resettable)


func update(input_: InputPackage, delta: float) -> void:
	# var TURN_SPEED := default_sp.TURN_SPEED
	var SPEED_MULT := 1.0

	match PREV_ACTION:
		Leg.Act.idle:
			SPEED_MULT = speed_mult_from_idle.update(delta)


	SPEED_MULT *= opposite_dir_change.speed_dip_update(delta)
	SPEED_MULT *= slight_dir_change.speed_dip_update(delta)
	SPEED_MULT *= slightest_dir_change.speed_dip_update(delta)

	var _sp_config := SpeedConfig.new(default_sp, SPEED_MULT, curr_direction.get_curr_speed())
	
	pm().look_at_target(delta, _sp_config)

	if curr_direction.is_pure_vertical():
		pm().move_forward_or_back(curr_direction.get_dir_int(), delta, _sp_config)
	else:
		pm().move_strafe_with_forward(input_, -curr_direction.get_dir_int(), delta, _sp_config) # note the minus
	
	opposite_dir_change.async_change_update(delta)
	slight_dir_change.async_change_update(delta)

	var new_dir := input_.detect_strafe_dir()
	if new_dir != curr_direction.get_curr_dir():
		print_.lsm_action_strafe(pp.on_upd, pp.s("new dir", curr_direction.pp_curr_dir(), "=>", Direction.name_(new_dir)))
	
	match curr_direction.would_be_change_of_type(new_dir):
		StrafeDirection.ChangeType.OPPOSITE:
			if opposite_dir_change.cooldown.update(delta):
				opposite_dir_change.speed_dip_init()
				opposite_dir_change.async_change_init(_change_dir.bind(true, new_dir))
				
				u.reset_all(_changers_cooldown)
				print_.lsm_action_strafe("", "~~ OPPOSITE dir change and dip triggered")

		StrafeDirection.ChangeType.SLIGHT:
			if slight_dir_change.cooldown.update(delta):
				slight_dir_change.speed_dip_init()
				slight_dir_change.async_change_init(_change_dir.bind(false, new_dir))
				
				u.reset_all(_changers_cooldown)
				print_.lsm_action_strafe("", "~~ SLIGHT dir change and dip triggered")
		
		StrafeDirection.ChangeType.SLIGHTEST:
			if slightest_dir_change.cooldown.update(delta):
				_change_dir(false, new_dir)
				
				u.reset_all(_changers_cooldown)
				print_.lsm_action_strafe("", "~~ SLIGHTEST dir change")

		StrafeDirection.ChangeType.SAME:
			u.reset_all(_changers_cooldown)


	get_animator_manager().set_global_speed_scale(SPEED_MULT)


func _change_dir(is_opposite_change: bool, new_dir: Direction.Dir):
	# ?? question: is it ok that we re evalutaing dir. bake into callback?
	var actual_new_dir := InputManager.current_input.detect_strafe_dir()
	curr_direction.set_direction(actual_new_dir)
	print_.lsm_action_strafe("", pp.s("_change_dir to", curr_direction.pp_curr_dir()))
	_switch_animation(is_opposite_change)


func animate(): # ▶️
	anim = anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	set_anim_to_play()


var sync_loco_anim_correction: float = 0.18
var __dev_add: float = 0.0


func _switch_animation(is_opposite_change: bool):
	var next_anim := anim_container.get_by_anim_id(curr_direction.get_curr_anim_id())
	var curr_anim := anim

	var _custom_blend_time = blend_time.calculate_actual(PREV_ACTION)
	var _custom_start_time_offset = start_time_offset.calculate_actual(PREV_ACTION)

	
	if next_anim.anim_id == curr_anim.anim_id:
		print_.lsm_action_strafe("", "_switch_animation same anim, won't switch")
		return

	if curr_anim.anim_id in curr_direction.get_all_anim_ids():
		if curr_anim.anim_id == A.strafe.combat_run_b and next_anim.anim_id in [A.strafe.strafe_L, A.strafe.strafe_R]:
			sync_loco_anim_correction = 0.0 + __dev_add
			__log_action(em.pin, em.mark)
		var r := sync_with_curr_loco_anim(next_anim, sync_loco_anim_correction)
		if r != -1:
			_custom_start_time_offset = r
		# for perfect smoothness it should be equal to timer cooldowns
		_custom_blend_time = 0.24 if is_opposite_change else 0.3
	else:
		_custom_blend_time = 0.3
		print_.warn(action_name + "_switch_animation but not from strafe anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!

	set_anim_to_play(_custom_blend_time, _custom_start_time_offset)


# func _input(event):
	# __dev_add = u._dev_change_t34_param(event, __dev_add, "__dev_add", 0.05)
