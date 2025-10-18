## are instantiated once and live in a shared pool instead of being a copy per behavior. 
class_name LegsAction
extends BaseAction

var legs_sm: LegsSM

var motion_type: String ## see MotionType

var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()

var SPEED_SCALE: float = 1.0

var blend_time_by_action = {}


## to override if needed
func initialise() -> void:
	pass

func pm() -> PlayerMovement:
	return legs_sm.player_sm.player_movement

func get_player() -> Princess:
	return legs_sm.player_sm.player

func _update(input_: InputPackage, _delta: float):
	update(input_, _delta)
	# _apply_residual_rotation()

## Not abstract! It can be empty. (double action)
func update(input_: InputPackage, _delta: float):
	pass


func _on_exit_action() -> void:
	legs_sm.prev_action = self
	# print_.lsm_action("", pp.s("prev_action_name is set to ", pp.in_q(curr_action_name)))
	on_exit_action()


## to override
func on_exit_action() -> void:
	pass


## experimental and not used 
func _apply_residual_rotation():
	# If we blend to non root rot anim from root rot anim (e.g. turn_180 -> run),
	# then we need to apply root rot leftover separately
	# (curr non root rot action doesn't know anything about root rot management)
	if animator_manager.is_blending() \
		and legs_sm.prev_action.anim.uses_root_rotation \
		and not anim.uses_root_rotation:
			var rotation_delta = animator_manager.get_prev_root_rotation()
			if abs(rotation_delta) > 0.001:
				# print(u.fr() + "[RESIDUAL_ROT] Action '%s' applying residual rotation of %.4f from prev action '%s'" % [action_name, rotation_delta, legs_sm.prev_action.action_name])
				get_player().rotate_y(rotation_delta)


## default implementation. Called automatically.
## Use cases to override: mute playing animation or using situational blend_time.
func animate(): # ▶️
	__log_anim(default_blend_time, 0.0)
	animator_manager.set_anim_to_play(anim.anim_id, default_blend_time)


## Common move/rotate logic. If needed, actions should explicitely call in update()


## TURN LOGIC
# region: code 


func calculate_target_angle(input_: InputPackage) -> float:
	var target_angle: float
	if input_.reverse_data.is_reversed():
		target_angle = - PI + 0.05
		prints("\n\t target ∠:", pp.rad2deg(target_angle))
		prints("\t Reverse type and full data", input_.reverse_data.type, input_.reverse_data)
	else:
		var _signed_angle = get_player().model.__angle_between_player_and_input(input_, 0.016, true)
		target_angle = wrapf(_signed_angle, -PI, PI)
		prints("\n\t target ∠:", pp.rad2deg(target_angle), "t ∠ before wrapf", _signed_angle)
	return target_angle


func turn_direction_by_target_angle(target_angle: float) -> String:
	var turn_direction: String
	if signf(target_angle) <= 0:
		turn_direction = TurnData.TURN_DIR_RIGHT
		if signf(target_angle) == 0: print_.warn("Turn angle is zero; defaulting to a 'right' turn.")
	else:
		turn_direction = TurnData.TURN_DIR_LEFT
	prints("\t turn decision:", turn_direction)
	return turn_direction


# endregion

## ANIMS BLEND TIMES / OFFSETS ETC
# region: code 


func sync_with_prev_loco_anim(next_anim_correction: float = 0.0) -> float:
	var result_offset = -1
	# NOTE: Action is switched, but animator still treats an anim from prev action as "current" 
	#       (before current action hits set_anim_to_play)
	var prev_anim_progress = animator_manager.get_current_anim_effective_progress()
	var prev_anim = legs_sm.prev_action.anim
	var next_anim = anim
	var prev_l_leg_contact = prev_anim.get_marker_by_name(Marker.Name.LOCO_LOOP_L_LEG_FULL_CONTACT)
	var next_l_leg_contact = next_anim.get_marker_by_name(Marker.Name.LOCO_LOOP_L_LEG_FULL_CONTACT)
	if prev_l_leg_contact and next_l_leg_contact:
		# print("~~prev_l_leg_contact and next_l_leg_contact", prev_l_leg_contact.time, next_l_leg_contact.time)
		result_offset = AnimHelpers.calculate_synced_anim_offset(
			prev_anim_progress,
			prev_anim.duration,
			prev_l_leg_contact.time,
			next_anim.duration,
			next_l_leg_contact.time + next_anim_correction
		)
	return result_offset


func sync_with_curr_loco_anim(next_anim: AnimationData, next_anim_correction: float = 0.0) -> float:
	var result_offset = -1
	var curr_anim_progress = animator_manager.get_current_anim_effective_progress()
	var curr_anim = anim
	var curr_l_leg_contact = curr_anim.get_marker_by_name(Marker.Name.LOCO_LOOP_L_LEG_FULL_CONTACT)
	var next_l_leg_contact = next_anim.get_marker_by_name(Marker.Name.LOCO_LOOP_L_LEG_FULL_CONTACT)
	if curr_l_leg_contact and next_l_leg_contact:
		# print("~~prev_l_leg_contact and next_l_leg_contact", prev_l_leg_contact.time, next_l_leg_contact.time)
		result_offset = AnimHelpers.calculate_synced_anim_offset(
			curr_anim_progress,
			curr_anim.duration,
			curr_l_leg_contact.time,
			next_anim.duration,
			next_l_leg_contact.time + next_anim_correction
		)
	return result_offset

## return -1 in case of problems or default value
func calculate_blend_time_from_prev_anim_marker(action_name_: String, marker_name_: String, default_value: float = -1) -> float:
	var blend_time: float = -1
	var _anim := container.legs_action_by_name(action_name_).anim
	if not _anim:
		print_.warn("blend_time == -1 inside calculate_blend_time_from_prev_anim_marker")
		return default_value
	var _marker_time := _anim.get_marker_time_by_name(marker_name_)
	if _marker_time == -1:
		print_.warn("blend_time == -1 inside calculate_blend_time_from_prev_anim_marker")
		return default_value
	blend_time = _anim.duration - _marker_time
	return blend_time

# endregion


func velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	return get_player().model.__velocity_by_input(input_, delta)


func __log_anim(blend_time, start_time_offset = 0.0):
	print_.lsm_action_anim(action_name, anim.anim_name, legs_sm.prev_action.action_name, blend_time, start_time_offset)
