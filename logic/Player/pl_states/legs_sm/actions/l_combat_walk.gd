extends LegsAction

enum WalkDirEnum {FORWARD, BACKWARD}

@export var accel_from_idle_curve: Curve
@export var dir_change_curve: Curve

var dir_change_cooldown := DelayTimer.new()
var change_dir_timer = DelayCallbackTimer.new()

var speed_mult_from_idle = EaseCurveInterpolator.new()
var speed_dip_from_dir_change = EaseCurveInterpolator.new()


const FORWARD_SPEED = 1.3
const BACKWARD_SPEED = 1.2
var ACCEL_FROM_IDLE_TIME: float = 0.4
var DIR_CHANGE_TIME: float = 0.3


var curr_direction: DirectionData = DirectionData.new()


class DirectionData:
	var direction: WalkDirEnum
	var default_speed: float
	var anim_id: String

	func init_from_walk_dir(walk_dir: WalkDirEnum):
		direction = walk_dir
		match walk_dir:
			WalkDirEnum.FORWARD:
				default_speed = FORWARD_SPEED
				anim_id = A.combat_walk

			WalkDirEnum.BACKWARD:
				default_speed = BACKWARD_SPEED
				anim_id = A.combat_walk_back

	func get_dir_int() -> int:
		return 1 if direction == WalkDirEnum.FORWARD else -1

	func get_anims() -> Array[String]:
		return [A.combat_walk, A.combat_walk_back]


func initialise():
	dir_change_cooldown.initialise(DIR_CHANGE_TIME)
	

func _update_walk_direction(input: InputPackage, on_enter: bool = false) -> WalkDirEnum:
	var new_dir = WalkDirEnum.FORWARD if input.forward_input > 0.0 else WalkDirEnum.BACKWARD
	if new_dir != curr_direction.direction or on_enter:
		print_.lsm_action(action_name, pp.s("fwd-inp/decision", input.forward_input, new_dir))
	return new_dir


func on_enter_action(input: InputPackage) -> void:
	curr_direction.init_from_walk_dir(_update_walk_direction(input, true))
	dir_change_cooldown.reset()
	change_dir_timer.reset()

	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)


func on_exit_action() -> void:
	speed_mult_from_idle.reset()
	speed_dip_from_dir_change.reset()
	animator_manager.reset_global_speed_scale()


func update(input: InputPackage, delta: float) -> void:
	var SPEED_MULT = 1.0

	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			SPEED_MULT = speed_mult_from_idle.update(delta)
	
	if speed_dip_from_dir_change.is_in_progress():
		SPEED_MULT = speed_dip_from_dir_change.update(delta)

	look_at_target(delta)

	var sp_config = SpeedConfig.new(SPEED_MULT, curr_direction.default_speed)
	move_forward_or_back(curr_direction.get_dir_int(), delta, sp_config)
	
	change_dir_timer.update(delta)

	var new_dir = _update_walk_direction(input)
	if new_dir != curr_direction.direction:
		print_.lsm_action(action_name, " ~~upd new_dir != curr_direction.direction")
		if dir_change_cooldown.update(delta):
			speed_dip_from_dir_change.initialise(dir_change_curve, DIR_CHANGE_TIME)
			change_dir_timer.initialise(DIR_CHANGE_TIME / 2.0, _on_change_dir_timer_complete)
			dir_change_cooldown.reset()
			print_.lsm_action(action_name, "~~ Direction change / dip triggered")

	animator_manager.set_global_speed_scale(SPEED_MULT)


func _on_change_dir_timer_complete():
	var new_dir = _update_walk_direction(InputManager.current_input)
	print_.lsm_action(action_name, "~~ _on_change_dir_timer_complete, new_dir: " + str(new_dir))
	curr_direction.init_from_walk_dir(new_dir)
	_switch_animation()


func animate(): # ▶️
	var blend_time := 0.3
	anim = anim_container.get_by_name(curr_direction.anim_id)
	__log_anim(blend_time)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time)


func _switch_animation():
	var next_anim = anim_container.get_by_name(curr_direction.anim_id)
	
	var start_offset = 0
	var blend_time := 0.2

	if next_anim.anim_name == anim.anim_name:
		print_.lsm_action(action_name, "~~ _switch_animation same anim, won't switch")
		return
	elif anim.anim_name in [curr_direction.get_anims()]:
		var r = sync_with_curr_loco_anim(next_anim, _next_anim_correction)
		if r != -1:
			start_offset = r
		blend_time = 0.1
	else:
		blend_time = 0.3
		print_.lsm_action(action_name, "~~ _switch_animation but not from walk anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!

	__log_anim(blend_time, start_offset)
	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_offset)


var _next_anim_correction = 0.93
func _input(event):
	# _dev_add_blend = u._dev_change_t12_param(event, _dev_add_blend, "_dev_add_blend", 0.05)
	_next_anim_correction = u._dev_change_t34_param(event, _next_anim_correction, "_next_anim_correction", 0.05)
