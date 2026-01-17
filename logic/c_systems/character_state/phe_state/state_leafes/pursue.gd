extends BasePHELeaf
class_name PHEPursue


var speed_from_inherited := FloatLinearInterpolator.new()
var speed_from_mode_change := FloatLinearInterpolator.new()
var angular_sp := FloatLinearInterpolator.new()

var _resettable := [
	speed_from_inherited,
	speed_from_mode_change,
	angular_sp,
]


var ANIM_FAST := PHEA.loco.run_forward
var ANIM_FAST_ANGRY := PHEA.loco.combat_run_forward
var ANIM_SLOW := PHEA.loco.walk_forward
var ANIM_SLOW_ANGRY := PHEA.loco.combat_walk_forward

const FAST = "fast"
const SLOW = "slow"

var _fast_preset := ActionModeSwitcher.Preset.new(FAST, 5.0, ANIM_FAST)
var _slow_preset := ActionModeSwitcher.Preset.new(SLOW, 1.7, ANIM_SLOW)

var _fast_angry_preset := ActionModeSwitcher.Preset.new(FAST, 5.0 + 6.0, ANIM_FAST_ANGRY)
var _slow_angry_preset := ActionModeSwitcher.Preset.new(SLOW, 1.7 + 0.4, ANIM_SLOW_ANGRY)


var curr_mode: ActionModeSwitcher

func initialise() -> void:
	default_sp.ANGULAR_SPEED = 2.5
	
	blend_time.set_by_prev_action({
		PHES.Leaf.awaken: 0.3,
		PHES.Leaf.combat_idle: 0.3,
	})

	curr_mode = ActionModeSwitcher.new(_slow_preset, _fast_preset)


func _decide_on_mode_on_enter():
	if not me.angry_raised:
		curr_mode = ActionModeSwitcher.new(_slow_preset, _fast_preset)
	else:
		curr_mode = ActionModeSwitcher.new(_slow_angry_preset, _fast_angry_preset)

	var dist := distance_to_player()
	var _reason: String = ""
	if not me.angry_raised:
		if dist >= config.REAL_FAR():
			curr_mode.set_mode(FAST)
			if __ELA(): _reason += "dist > REAL_FAR"
		else:
			if __ELA(): _reason += "dist < REAL_FAR"
			curr_mode.set_mode(SLOW)
	else:
		if dist >= config.COMBAT_RAD() - 0.2:
			curr_mode.set_mode(FAST)
		else:
			curr_mode.set_mode(SLOW)

	if __ELA(): __log_decide_on_mode(true, "-x-", _reason)


func _update_mode() -> bool:
	var dist := distance_to_player()
	var _reason: String = ""
	var _old_mode_name := curr_mode.get_curr_mode_name()
	match _old_mode_name:
		FAST:
			if dist < config.CLOSE_TO_ORBIT() - fvalue_angry(0.0, 3.0):
				if __ELA(): _reason += "dist < CLOSE_TO_ORBIT"
				curr_mode.set_mode(svalue_angry(SLOW, FAST))
		SLOW:
			if dist >= config.REAL_FAR() - fvalue_angry(0.0, 3.0):
				if __ELA(): _reason += "dist > REAL_FAR"
				curr_mode.set_mode(FAST)

	if _old_mode_name != curr_mode.get_curr_mode_name():
		if __ELA(): __log_decide_on_mode(false, _old_mode_name, _reason)
		return true
	else:
		return false


func on_enter_state() -> void:
	u.reset_all(_resettable)

	_decide_on_mode_on_enter()

	anim = anim_container.get_by_anim_id(curr_mode.get_curr_anim_id())
	
	var _inherited_speed := e_movement.get_curr_velocity_len()
	if __ELA(): __log_ent("_inherited_speed, speed will be ", _inherited_speed, "->", curr_mode.get_curr_speed())

	speed_from_inherited.initialise(_inherited_speed, curr_mode.get_curr_speed(), 0.4)
	angular_sp.initialise(0.4, default_sp.ANGULAR_SPEED, 0.8)


func on_exit_state() -> void:
	u.reset_all(_resettable)
	get_animator_manager().reset_global_speed_scale()


func update(delta: float) -> void:
	var ANGULAR_SPEED := default_sp.ANGULAR_SPEED
	var CURR_SPEED := curr_mode.get_curr_speed()
	# var __initial_speed := CURR_SPEED
	
	if _update_mode():
		_on_mode_switch()
	
	ANGULAR_SPEED = angular_sp.update(delta)
	if speed_from_inherited.is_in_progress():
		CURR_SPEED = speed_from_inherited.update(delta)
	# var __speed_after_inherited := CURR_SPEED
	if speed_from_mode_change.is_in_progress():
		CURR_SPEED = speed_from_mode_change.update(delta)
	# var __speed_after_mode_change := CURR_SPEED

	var speed_config := SpeedConfig.new(default_sp, 1.0, CURR_SPEED, ANGULAR_SPEED)
	e_movement.move_rotate_towards_player(delta, speed_config)
	
	# __log_upd("target/inherited/final %5.2f  %5.2f  %5.2f " % [__initial_speed, __speed_after_inherited, __speed_after_mode_change])
	if CURR_SPEED > 0.1:
		get_animator_manager().set_global_speed_scale(e_movement.get_curr_velocity_len() / CURR_SPEED)


func _on_mode_switch():
	if __ELA(): __log_upd("Switching pursue curr_mode to", curr_mode.get_curr_mode_name(), "speed from", e_movement.get_curr_velocity_len(), "to", curr_mode.get_curr_speed(), "over 0.3")
	_switch_animation()
	# to smooth the speed change
	speed_from_mode_change.initialise(e_movement.get_curr_velocity_len(), curr_mode.get_curr_speed(), 0.3)
	

func _switch_animation():
	var next_anim := anim_container.get_by_anim_id(curr_mode.get_curr_anim_id())
	var curr_anim := anim

	if next_anim.anim_id == curr_anim.anim_id:
		if __ELA(): print_.dev("", "_switch_animation same anim, won't switch")
		return

	var _custom_blend_time := blend_time.calculate_actual(PREV_LEAF)
	var _custom_start_time_offset := start_time_offset.calculate_actual(PREV_LEAF)


	if curr_anim.anim_id in [ANIM_FAST, ANIM_FAST_ANGRY, ANIM_SLOW, ANIM_SLOW_ANGRY]:
		var r := sync_with_curr_loco_anim(next_anim, 0.0)
		if r != -1:
			_custom_start_time_offset = r
		_custom_blend_time = 0.2
	else:
		_custom_blend_time = 0.3
		__log_warn(state_name + " _switch_animation but not from strafe anim O_o")
	
	anim = next_anim # only after sync_with_curr_loco_anim!
	
	set_anim_to_play(_custom_blend_time, _custom_start_time_offset)


func __log_decide_on_mode(on_enter: bool, _old_mode_name: String, _reason: String):
	var _curr_mode_name := curr_mode.get_curr_mode_name()
	if on_enter:
		if __ELA(): __log_ent(_reason, "-> Initial curr_mode:", _curr_mode_name)
	else:
		if __ELA(): __log_upd(_old_mode_name, "-> Change to", _curr_mode_name, "Reason:", _reason)
