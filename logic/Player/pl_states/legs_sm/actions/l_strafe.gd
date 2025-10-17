extends LegsAction

@export var accel_from_idle_curve: Curve
@export var dir_change_curve: Curve # for opposite direction changes
@export var slght_dir_change_curve: Curve # for slight direction changes


var speed_mult_from_idle = EaseCurveInterpolator.new()

const ACCEL_FROM_IDLE_TIME: float = 0.35

const OPP_DIR_CHANGE_DURATION: float = 0.16
const SLIGHT_DIR_CHANGE_DURATION: float = 0.08

const ANIM_L: String = A.strafe_L
const ANIM_R: String = A.strafe_R
const SPEED_R: float = 2.1
const SPEED_L: float = 2.0

var sync_loco_anim_correction: float = 0.18

var curr_direction: StrafeDirection


var opposite_dir_change := StrafeDirChange.new()
var slight_dir_change := StrafeDirChange.new()


func initialise():
	curr_direction = StrafeDirection.new(SPEED_R, ANIM_R, SPEED_L, ANIM_L)
	opposite_dir_change.initialise(dir_change_curve, OPP_DIR_CHANGE_DURATION)
	slight_dir_change.initialise(slght_dir_change_curve, SLIGHT_DIR_CHANGE_DURATION)
	

func on_enter_action(input: InputPackage) -> void:
	curr_direction.set_direction(curr_direction.detect_dir_from_input(input, true))
	
	opposite_dir_change.reset()
	slight_dir_change.reset()

	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)


func on_exit_action() -> void:
	speed_mult_from_idle.reset()
	animator_manager.reset_global_speed_scale()


func update(input: InputPackage, delta: float) -> void:
	var SPEED_MULT = 1.0

	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			SPEED_MULT = speed_mult_from_idle.update(delta)
	
	SPEED_MULT *= opposite_dir_change.speed_dip_update(delta)
	SPEED_MULT *= slight_dir_change.speed_dip_update(delta)

	##
	look_at_target(delta)

	var _sp_config = SpeedConfig.new(SPEED_MULT, curr_direction.get_curr_speed())
	move_strafe_with_forward(input, -curr_direction.get_dir_int(), delta, _sp_config) # note the minus
	
	opposite_dir_change.async_change_update(delta)
	slight_dir_change.async_change_update(delta)

	var new_dir = curr_direction.detect_dir_from_input(input)
	if curr_direction.would_be_opposite_change(new_dir):
		if opposite_dir_change.cooldown.update(delta):
			print_.lsm_action_strafe("", "~~ opposite dir change and change_cooldown completed")
			opposite_dir_change.speed_dip_init()
			opposite_dir_change.async_change_init(_on_change_dir_timer_complete.bind(true))
			
			opposite_dir_change.cooldown.reset()
			slight_dir_change.cooldown.reset()
			print_.lsm_action_strafe("", "~~ opp dir change and dip triggered")

	elif curr_direction.would_be_slight_change(new_dir):
		if slight_dir_change.cooldown.update(delta):
			print_.lsm_action_strafe("", "~~ slight dir change and change_cooldown completed")
			slight_dir_change.speed_dip_init()
			slight_dir_change.async_change_init(_on_change_dir_timer_complete.bind(false))
			
			slight_dir_change.cooldown.reset()
			opposite_dir_change.cooldown.reset()
			print_.lsm_action_strafe("", "~~ slight dir change and dip triggered")

	else: # no change
		opposite_dir_change.cooldown.reset()
		slight_dir_change.cooldown.reset()


	animator_manager.set_global_speed_scale(SPEED_MULT)


func _on_change_dir_timer_complete(is_opposite_change: bool):
	var new_dir = curr_direction.detect_dir_from_input(InputManager.current_input)
	print_.lsm_action_strafe("", "_on_change_dir_timer_complete, new_dir: " + str(new_dir))
	curr_direction.set_direction(new_dir)
	_switch_animation(is_opposite_change)


func animate(): # ▶️
	var blend_time := 0.3
	anim = anim_container.get_by_name(curr_direction.get_curr_anim_id())
	__log_anim(blend_time)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time)


func _switch_animation(is_opposite_change: bool):
	var next_anim = anim_container.get_by_name(curr_direction.get_curr_anim_id())
	
	var start_offset = 0
	var blend_time := 0.2

	if next_anim.anim_id == anim.anim_id:
		print_.lsm_action_strafe("", "_switch_animation same anim, won't switch")
		return

	if anim.anim_id in curr_direction.get_all_anims():
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
