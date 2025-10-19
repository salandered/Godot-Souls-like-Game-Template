extends LegsAction

@export var accel_from_idle_curve: Curve
@export var dir_change_curve: Curve # for opposite direction changes
@export var slght_dir_change_curve: Curve # for slight direction changes


var speed_mult_from_idle = EaseCurveInterpolator.new()

const ACCEL_FROM_IDLE_TIME: float = 0.35

const OPP_DIR_CHANGE_DURATION: float = 0.16
const SLIGHT_DIR_CHANGE_DURATION: float = 0.1
const SLIGHTEST_DIR_CHANGE_DURATION: float = 0.08

const ANIM_L: String = A.strafe.strafe_L
const ANIM_R: String = A.strafe.strafe_R
const SPEED_R: float = 2.1
const SPEED_L: float = 2.0

const ANIM_F: String = A.strafe.combat_run_f
const ANIM_B: String = A.strafe.combat_run_b
const SPEED_F: float = 1.9
const SPEED_B: float = 1.6


var curr_direction: StrafeDirection


var opposite_dir_change := StrafeDirChange.new()
var slight_dir_change := StrafeDirChange.new()
var slightest_dir_change := StrafeDirChange.new()


func __reset_changers():
	opposite_dir_change.reset()
	slight_dir_change.reset()
	slightest_dir_change.reset()

func __reset_changers_cooldown():
	opposite_dir_change.cooldown.reset()
	slight_dir_change.cooldown.reset()
	slightest_dir_change.cooldown.reset()


func initialise():
	curr_direction = StrafeDirection.new(SPEED_R, ANIM_R, SPEED_L, ANIM_L, SPEED_F, ANIM_F, SPEED_B, ANIM_B)
	opposite_dir_change.initialise(dir_change_curve, OPP_DIR_CHANGE_DURATION)
	slight_dir_change.initialise(slght_dir_change_curve, SLIGHT_DIR_CHANGE_DURATION)
	slightest_dir_change.initialise(slght_dir_change_curve, SLIGHTEST_DIR_CHANGE_DURATION)


func on_enter_action(input_: InputPackage) -> void:
	var _dir := input_.detect_strafe_dir()
	print_.lsm_action_strafe(pp.on_ent, "detected strafe dir: " + StrafeDir.name_(_dir))
	curr_direction.set_direction(_dir)
	
	__reset_changers()

	match player_sm.get_prev_action().action_name:
		Leg.Act.idle:
			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)


func on_exit_action() -> void:
	speed_mult_from_idle.reset()
	animator_manager.reset_global_speed_scale()


func update(input_: InputPackage, delta: float) -> void:
	var SPEED_MULT = 1.0

	match player_sm.get_prev_action().action_name:
		Leg.Act.idle:
			SPEED_MULT = speed_mult_from_idle.update(delta)
	

	SPEED_MULT *= opposite_dir_change.speed_dip_update(delta)
	SPEED_MULT *= slight_dir_change.speed_dip_update(delta)
	SPEED_MULT *= slightest_dir_change.speed_dip_update(delta)

	##
	pm().look_at_target(delta)


	var _sp_config = SpeedConfig.new(default_sp, SPEED_MULT, curr_direction.get_curr_speed())
	if curr_direction.is_pure_vertical():
		pm().move_forward_or_back(curr_direction.get_dir_int(), delta, _sp_config)
	else:
		pm().move_strafe_with_forward(input_, -curr_direction.get_dir_int(), delta, _sp_config) # note the minus
	
	opposite_dir_change.async_change_update(delta)
	slight_dir_change.async_change_update(delta)

	var new_dir = input_.detect_strafe_dir()
	if new_dir != curr_direction.get_curr_dir():
		print_.lsm_action_strafe(pp.on_upd, pp.s("new dir", curr_direction.pp_curr_dir(), "=>", StrafeDir.name_(new_dir)))
	match curr_direction.would_be_change_of_type(new_dir):
		StrafeDirection.ChangeType.OPPOSITE:
			if opposite_dir_change.cooldown.update(delta):
				opposite_dir_change.speed_dip_init()
				opposite_dir_change.async_change_init(_change_dir.bind(true))
				
				__reset_changers_cooldown()
				print_.lsm_action_strafe("", "~~ OPPOSITE dir change and dip triggered")

		StrafeDirection.ChangeType.SLIGHT:
			if slight_dir_change.cooldown.update(delta):
				slight_dir_change.speed_dip_init()
				slight_dir_change.async_change_init(_change_dir.bind(false))
				
				__reset_changers_cooldown()
				print_.lsm_action_strafe("", "~~ SLIGHT dir change and dip triggered")
		
		StrafeDirection.ChangeType.SLIGHTEST:
			if slightest_dir_change.cooldown.update(delta):
				_change_dir(false)
				
				__reset_changers_cooldown()
				print_.lsm_action_strafe("", "~~ SLIGHTEST dir change")

		StrafeDirection.ChangeType.SAME:
			__reset_changers_cooldown()


	animator_manager.set_global_speed_scale(SPEED_MULT)


func _change_dir(is_opposite_change: bool):
	# ?? question: is it good that we re evalutaing dir. bake into callback?
	var new_dir = InputManager.current_input.detect_strafe_dir()
	curr_direction.set_direction(new_dir)
	print_.lsm_action_strafe("", pp.s("_change_dir to", curr_direction.pp_curr_dir()))
	_switch_animation(is_opposite_change)


func animate(): # ▶️
	var blend_time := 0.3
	anim = anim_container.get_by_name(curr_direction.get_curr_anim_id())
	__log_anim(blend_time)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time)


var sync_loco_anim_correction: float = 0.18
var __dev_add: float = 0.0

# TODO idea: switch animatiions only if blend time is complete.
# animations are in queue, while direction is changes as usual
func _switch_animation(is_opposite_change: bool):
	var next_anim = anim_container.get_by_name(curr_direction.get_curr_anim_id())
	var curr_anim = anim

	var start_offset = 0
	var blend_time := 0.2

	if next_anim.anim_id == curr_anim.anim_id:
		print_.lsm_action_strafe("", "_switch_animation same anim, won't switch")
		return

	if next_anim.anim_id in curr_direction.get_all_anims() and curr_anim.anim_id in curr_direction.get_all_anims():
		if curr_anim.anim_id == A.strafe.combat_run_b and next_anim.anim_id in [A.strafe.strafe_L, A.strafe.strafe_R]:
			sync_loco_anim_correction = 0.0 + __dev_add
			print(em.pin, em.mark)
			print(em.pin, em.mark)
			print(em.pin, em.mark)
		var r = sync_with_curr_loco_anim(next_anim, sync_loco_anim_correction)
		if r != -1:
			start_offset = r
		# for perfect smoothness it should be equal to timer cooldowns
		blend_time = 0.2 if is_opposite_change else 0.1
	else:
		blend_time = 0.3
		print_.warn(action_name + "_switch_animation but not from strafe anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!

	__log_anim(blend_time, start_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_offset)


func _input(event):
	__dev_add = u._dev_change_t34_param(event, __dev_add, "__dev_add", 0.05)
