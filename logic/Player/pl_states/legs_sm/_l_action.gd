## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends BaseAction
class_name LegsAction

var legs_sm: LegsSM

var motion_type: String ## see MotionType

## meant to be overriden if action uses them
var SPEED: float = 2.0
## how fast the character moves forward while rotating
## usually lesser than SPEED
var TURN_SPEED: float = 1.6 # todo: consider tying to SPEED
## how fast the character rotates (changes facing direction)
## 4 means ~ 230. max a player can turn in one frame is ANGULAR_SPEED * delta == 4.0 * 0.0167 = ~ 3.8 degrees.
var ANGULAR_SPEED: float = 4.0
var SPEED_SCALE: float = 1.0

var blend_time_by_action = {}


func get_player() -> Princess:
	return legs_sm.player_sm.player

func _update(_input: InputPackage, _delta: float):
	update(_input, _delta)
	# _apply_residual_rotation()

## Not abstract! It can be empty. (double action)
func update(_input: InputPackage, _delta: float):
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

## MOVING WITH INPUT VECTOR
# region: code

func process_input_vector(input: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(input, delta, speed_config)
	_move_with_input_vector(angle, input, delta, speed_config)
	get_player().rotate_y(angle.value)

func move_with_input_vector(input: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(input, delta, speed_config)
	_move_with_input_vector(angle, input, delta, speed_config)


func rotate_with_input_vector(input: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var angle := _calculate_allowed_angle(input, delta, speed_config)
	get_player().rotate_y(angle.value)


func _move_with_input_vector(angle: AllowedAngle, input: InputPackage, delta: float, speed_config: SpeedConfig):
	var _speed = speed_config.get_override_speed(SPEED)
	var _turn_speed = speed_config.get_override_turn_speed(TURN_SPEED)

	var _face_dir = get_player().basis.z
	var face_dir_rotated := _face_dir.rotated(Vector3.UP, angle.value)

	if angle.cut:
		get_player().velocity = face_dir_rotated * _turn_speed * speed_config.speed_multiplier
	else:
		get_player().velocity = face_dir_rotated * _speed * speed_config.speed_multiplier


func _calculate_allowed_angle(input: InputPackage, delta: float, speed_config: SpeedConfig) -> AllowedAngle:
	var _angular_speed = ANGULAR_SPEED
	if speed_config.override_angular_sp != -1.0:
		_angular_speed = speed_config.override_angular_sp

	var input_direction := velocity_by_input(input, delta).normalized()

	var _face_dir = get_player().basis.z
	var angle = _face_dir.signed_angle_to(input_direction, Vector3.UP)

	if abs(angle) >= _angular_speed * delta: # reads as 'max rotation allowed in this frame'
		return AllowedAngle.new(sign(angle) * _angular_speed * delta, true)
	else:
		return AllowedAngle.new(angle)

class AllowedAngle:
	var value: float
	var cut: float

	func _init(_value, _cut: bool = false) -> void:
		value = _value
		cut = _cut


# endregion


## MOVING WITH ROOT
# region: code 

func move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	get_player().velocity = get_player().get_quaternion() * root_vel


func apply_root_rotation(rot_delta: float, target_angle_: float, accum_rot_: float, check_counter_rot: bool = false) -> Dictionary:
	var remaining_angle = target_angle_ - accum_rot_
	var _log_msg = "rem ∠ " + pp.rad2deg(remaining_angle) + ", rot delta " + pp.rad2deg(rot_delta)

	if check_counter_rot: # do we need this at all if animation s good?
		var is_counter_rotating = (rot_delta < 0 and remaining_angle > 0) or \
								  (rot_delta > 0 and remaining_angle < 0)
		if is_counter_rotating:
			prints(u.fr(), em.pin + "counter rotation, ending turn", _log_msg)
			return {"completed": true, "accum_rot": accum_rot_}

	if abs(rot_delta) >= abs(remaining_angle):
		get_player().rotate_y(remaining_angle)
		prints(u.fr(), "Turn complete .", _log_msg)
		return {"completed": true, "accum_rot": target_angle_}
	else:
		get_player().rotate_y(rot_delta)
		var new_rotation = accum_rot_ + rot_delta
		# prints(u.fr(), "applied", _log_msg)
		return {"completed": false, "accum_rot": new_rotation}


# endregion


## STRAFE MOVEMENT
# region: code 

## used with strafe behavior actions
func strafe_with_input_vector(input: InputPackage, delta: float, speed_config: SpeedConfig = null):
	if speed_config == null:
		speed_config = SpeedConfig.new()
	var _speed = speed_config.get_override_speed(SPEED)

	var desired_velocity = velocity_by_input(input, delta)
	if desired_velocity.is_zero_approx():
		get_player().velocity = Vector3.ZERO
		return

	var direction = desired_velocity.normalized()
	get_player().velocity = direction * _speed * speed_config.speed_multiplier


func look_at_target(use_model_front: bool = true) -> void:
	# Assuming camera lock implies a valid target exists.
	if legs_sm.area_awareness.is_camera_locked():
		var target_pos = get_player().fancy_camera.locked_target.global_position
		# Ignore the height difference for rotation to keep the character upright.
		target_pos.y = get_player().global_position.y
		u.safe_look_at(get_player(), target_pos, Vector3.UP, use_model_front)

# endregion


## TURN LOGIC
# region: code 


func calculate_target_angle(input: InputPackage) -> float:
	var target_angle: float
	if input.reverse_data.is_reversed:
		target_angle = - PI + 0.05
		prints("\n\t target ∠:", pp.rad2deg(target_angle))
		prints("\t Reverse type and full data", input.reverse_data.type, input.reverse_data)
	else:
		var _signed_angle = get_player().model.__angle_between_player_and_input(input, 0.016, true)
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
	var prev_l_leg_contact = prev_anim.get_marker_by_name(Marker.Name.LOCO_LOOP_L_LEG_FULL_CONTACT)
	var next_l_leg_contact = anim.get_marker_by_name(Marker.Name.LOCO_LOOP_L_LEG_FULL_CONTACT)
	if prev_l_leg_contact and next_l_leg_contact:
		# print("~~prev_l_leg_contact and next_l_leg_contact", prev_l_leg_contact.time, next_l_leg_contact.time)
		result_offset = AnimHelpers.calculate_synced_anim_offset(
			prev_anim_progress,
			prev_anim.duration,
			prev_l_leg_contact.time,
			anim.duration,
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


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	return get_player().model.__velocity_by_input(input, delta)


func __log_anim(blend_time, start_time_offset = 0.0):
	print_.lsm_action_anim(action_name, anim.anim_name, legs_sm.prev_action.action_name, blend_time, start_time_offset)
