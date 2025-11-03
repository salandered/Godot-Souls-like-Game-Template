extends LegsAction
class_name LegsLockedVertMoveAction

# @export var accel_from_idle_curve: Curve
# @export var dir_change_curve: Curve

# var dir_change_cooldown := DelayTimer.new()
# var change_dir_timer = DelayCallbackTimer.new()

# var speed_mult_from_idle = EaseCurveInterpolator.new()
# var speed_dip_from_dir_change = EaseCurveInterpolator.new()


# var ACCEL_FROM_IDLE_TIME: float
# var DIR_CHANGE_TIME: float

# var ANIM_F: String
# var ANIM_B: String
# var SPEED_F: float
# var SPEED_B: float

# var next_anim_correction: float

# var curr_direction: DualDirection


# ## NOTE: should be called at the end of initialise() of child classes
# func __initialise():
# 	## Forward = PRIMARY, Backward = SECONDARY
# 	curr_direction = DualDirection.new(SPEED_F, SPEED_B, ANIM_F, ANIM_B)
# 	dir_change_cooldown.initialise(DIR_CHANGE_TIME)
# 	__validate()


# func __validate() -> void:
# 	assert(ACCEL_FROM_IDLE_TIME > 0.0)
# 	assert(DIR_CHANGE_TIME > 0.0)
# 	assert(ANIM_F != "")
# 	assert(ANIM_B != "")
# 	assert(SPEED_F > 0.0)
# 	assert(SPEED_B > 0.0)
# 	assert(next_anim_correction > 0.0)


# func _update_walk_direction(input_: InputPackage, on_enter: bool = false) -> DualDirection.Dir:
# 	var new_dir = DualDirection.Dir.PRIMARY if input_.forward_input > 0.0 else DualDirection.Dir.SECONDARY
# 	# if new_dir != curr_direction.curr_direction or on_enter:
# 		# print_.lsm_action(action_name, pp.s("fwd-inp/decision", input_.forward_input, new_dir))
# 	return new_dir


# func on_enter_action(input_: InputPackage) -> void:
# 	curr_direction.set_direction(_update_walk_direction(input_, true))
# 	dir_change_cooldown.reset()
# 	change_dir_timer.reset()

# 	match legs_sm.prev_action.action_name:
# 		Leg.Act.idle:
# 			speed_mult_from_idle.initialise(accel_from_idle_curve, ACCEL_FROM_IDLE_TIME)


# func on_exit_action() -> void:
# 	speed_mult_from_idle.reset()
# 	speed_dip_from_dir_change.reset()
# 	animator_manager.reset_global_speed_scale()


# func update(input_: InputPackage, delta: float) -> void:
# 	var SPEED_MULT = 1.0

# 	match legs_sm.prev_action.action_name:
# 		Leg.Act.idle:
# 			SPEED_MULT = speed_mult_from_idle.update(delta)
	
# 	if speed_dip_from_dir_change.is_in_progress():
# 		SPEED_MULT = speed_dip_from_dir_change.update(delta)

# 	pm().look_at_target(delta)

# 	var sp_config = SpeedConfig.new(default_sp, SPEED_MULT, curr_direction.default_speed)
# 	# prints("~~~~", sp_config)
# 	pm().move_forward_or_back(curr_direction.get_dir_int(), delta, sp_config)
	
# 	change_dir_timer.update(delta)

# 	var new_dir = _update_walk_direction(input_)
# 	if new_dir != curr_direction.curr_direction:
# 		if dir_change_cooldown.update(delta):
# 			print_.lsm_action(action_name, " ~~upd new_dir != curr_dir and dir_change_cooldown completed")
# 			speed_dip_from_dir_change.initialise(dir_change_curve, DIR_CHANGE_TIME)
# 			change_dir_timer.initialise(DIR_CHANGE_TIME / 2.0, _on_change_dir_timer_complete)
# 			dir_change_cooldown.reset()
# 			print_.lsm_action(action_name, "~~ Direction change / dip triggered")

# 	animator_manager.set_global_speed_scale(SPEED_MULT)


# func _on_change_dir_timer_complete():
# 	var new_dir = _update_walk_direction(InputManager.current_input)
# 	print_.lsm_action(action_name, "~~ _on_change_dir_timer_complete, new_dir: " + str(new_dir))
# 	curr_direction.set_direction(new_dir)
# 	_switch_animation()


# func animate(): # ▶️
# 	var blend_time := 0.3
# 	anim = anim_container.get_by_name(curr_direction.anim_id)
# 	__log_anim(blend_time)
# 	animator_manager.set_anim_to_play(anim.anim_id, blend_time)


# func _switch_animation():
# 	var next_anim = anim_container.get_by_name(curr_direction.anim_id)
# 	var curr_anim = anim
	
# 	var start_offset = 0
# 	var blend_time := 0.2

# 	if next_anim.anim_id == curr_anim.anim_id:
# 		print_.lsm_action(action_name, "~~ _switch_animation same anim, won't switch")
# 		return
	
# 	if next_anim.anim_id in curr_direction.get_all_anims() and curr_anim.anim_id in curr_direction.get_all_anims():
# 		print_.lsm_action(action_name, "~~//" + next_anim.anim_id + str(curr_direction.get_anims()))

# 		var r = sync_with_curr_loco_anim(next_anim, next_anim_correction)
# 		if r != -1:
# 			start_offset = r
# 		blend_time = 0.1
# 	else:
# 		blend_time = 0.3
# 		print_.lsm_action(action_name, "~~ _switch_animation but not from vert move anim O_o")
	
# 	anim = next_anim # only after sync_with_curr_loco_anim!

# 	__log_anim(blend_time, start_offset)
# 	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_offset)
