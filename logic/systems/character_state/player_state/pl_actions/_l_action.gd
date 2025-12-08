@abstract
class_name LegsAction
extends BaseAction

var legs_sm: LegsSM


## to override if needed
func initialise() -> void:
	pass


func get_lsm_curr_action() -> LegsAction:
	return legs_sm.get_curr_action()

func get_lsm_prev_action() -> LegsAction:
	return legs_sm.get_prev_action()


## Not abstract! It can be empty. (double action)
func update(input_: InputPackage, delta: float):
	pass


## TURN LOGIC
# region 

func calculate_target_angle_by_input(input_: InputPackage) -> float:
	var target_angle: float
	if input_.reverse_data.is_reversed():
		target_angle = - PI + 0.05
		# prints("\n\t target ∠:", pp.rad2deg(target_angle))
		# prints("\t Reverse type and full data", input_.reverse_data.type, input_.reverse_data)
	else:
		var _signed_angle := pm().get_signed_angle_pl_input(input_, Constants.ONE_FRAME, true)
		target_angle = wrapf(_signed_angle, -PI, PI)
		# prints("\n\t target ∠:", pp.rad2deg(target_angle), "t ∠ before wrapf", _signed_angle)
	return target_angle


func calculate_target_angle_by_target(input_: InputPackage) -> float:
	var target_angle: float
	var _signed_angle := pm().get_signed_angle_pl_target()
	target_angle = wrapf(_signed_angle, -PI, PI)
	# prints("\n\t target ∠:", pp.rad2deg(target_angle), "t ∠ before wrapf", _signed_angle)
	return target_angle


func turn_direction_by_target_angle(target_angle: float) -> String:
	var turn_direction: String
	if signf(target_angle) <= 0:
		turn_direction = TurnData.TURN_DIR_RIGHT
		if signf(target_angle) == 0: print_.warn_raw(false, "Turn angle is zero; defaulting to a 'right' turn.")
	else:
		turn_direction = TurnData.TURN_DIR_LEFT
	# prints("\t turn decision:", turn_direction)
	return turn_direction

# endregion

## ANIMS BLEND TIMES / OFFSETS ETC
# region 

func sync_with_prev_loco_anim(next_anim_correction: float = 0.0) -> float:
	var prev_anim := container.l_action_by_name(PREV_ACTION).anim
	# NOTE: Action is switched, but animator still treats an anim from prev action as "current" 
	#       (before current action hits set_anim_to_play)
	var prev_anim_progress: float = get_animator_manager().get_curr_anim_effective_time_spent()
	var result_offset := AnimHelpers.sync_with_loco_anim(prev_anim, prev_anim_progress, anim, next_anim_correction)
	return result_offset

func sync_with_curr_loco_anim(next_anim: AnimationData, next_anim_correction: float = 0.0) -> float:
	var curr_anim_progress: float = get_animator_manager().get_curr_anim_effective_time_spent()
	var result_offset := AnimHelpers.sync_with_loco_anim(anim, curr_anim_progress, next_anim, next_anim_correction)
	return result_offset


## return -1 in case of problems or default value
func calculate_blend_time_from_prev_anim_marker(action_name_: String, marker_name_: String, default_value: float = -1, not_leg_action: bool = false) -> float:
	var blend_time_: float = -1
	var _anim: AnimationData
	if not_leg_action: # todo: oh
		_anim = container.pl_action_by_name(action_name_).anim
	else:
		_anim = container.l_action_by_name(action_name_).anim

	if not _anim:
		print_.warn_raw(false, "blend_time_ == -1 inside calculate_blend_time_from_prev_anim_marker")
		return default_value
	var _marker_time := _anim.get_marker_time_by_name(marker_name_)
	if _marker_time == -1:
		print_.warn_raw(false, "blend_time_ == -1 inside calculate_blend_time_from_prev_anim_marker")
		return default_value
	blend_time_ = _anim.duration - _marker_time
	return blend_time_


# endregion


## LOGS


func __log_function(prefix: String, ...parts: Array) -> void:
	print_.lsm_action(prefix, pp.list_(parts))
