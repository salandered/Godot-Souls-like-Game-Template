## Legs_behaviors states have the type called Legs_Actions, and legs_actions are instantiated once and live in a shared pool instead of being a copy per behavior. 
extends BaseAction
class_name LegsAction

var legs_sm: LegsSM

var motion_type: String ## see MotionType

## meant to be overriden if action uses them
var SPEED: float = 2.0
var TURN_SPEED: float = 2.0
## 4 means ~ 230. max a player can turn in one frame is ANGULAR_SPEED * delta == 4.0 * 0.0167 = ~ 3.8 degrees.
var ANGULAR_SPEED: float = 4.0
var SPEED_SCALE: float = 1.0

var blend_time_by_state = {
	
}

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


## experimental 
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
				player.rotate_y(rotation_delta)


## default implementation. Called automatically.
## Use cases to override: mute playing animation or using situational blend_time.
func animate(): # ▶️
	__log_anim(default_blend_time, 0.0)
	animator_manager.set_anim_to_play(anim.anim_id, default_blend_time)


## default implementation. If needed, actions should explicitely call in update()
func move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	player.velocity = player.get_quaternion() * root_vel


## Common process_input_vector logic. If needed, actions should explicitely call in update()
# region: code

func process_input_vector(input: InputPackage, delta: float, speed_multiplier: float = 1.0, override_speed: float = -1.0):
	var angle := _calculate_allowed_angle(input, delta)
	_move_with_input_vector(angle, input, delta, speed_multiplier, override_speed)
	_rotate_with_input_vector(angle, input, delta)


func move_with_input_vector(input: InputPackage, delta: float, speed_multiplier: float = 1.0, override_speed: float = -1.0):
	var angle := _calculate_allowed_angle(input, delta)
	_move_with_input_vector(angle, input, delta, speed_multiplier, override_speed)


func rotate_with_input_vector(input: InputPackage, delta: float):
	var angle := _calculate_allowed_angle(input, delta)
	_rotate_with_input_vector(angle, input, delta)


func _move_with_input_vector(angle: Angle, input: InputPackage, delta: float, speed_multiplier: float = 1.0, override_speed: float = -1.0):
	var speed = SPEED
	if override_speed != -1.0:
		speed = override_speed
	
	var _face_dir = player.basis.z
	var face_dir_rotated := _face_dir.rotated(Vector3.UP, angle.value)

	if angle.cut:
		player.velocity = face_dir_rotated * TURN_SPEED * speed_multiplier
	else:
		player.velocity = face_dir_rotated * speed * speed_multiplier


func _rotate_with_input_vector(angle: Angle, input: InputPackage, delta: float):
	player.rotate_y(angle.value)


func _calculate_allowed_angle(input: InputPackage, delta: float) -> Angle:
	var input_direction := velocity_by_input(input, delta).normalized()

	var _face_dir = player.basis.z
	var angle = _face_dir.signed_angle_to(input_direction, Vector3.UP)

	if abs(angle) >= ANGULAR_SPEED * delta: # reads as 'max rotation allowed in this frame'
		return Angle.new(sign(angle) * ANGULAR_SPEED * delta, true)
	else:
		return Angle.new(angle)


class Angle:
	var value: float
	var cut: float

	func _init(_value, _cut: bool = false) -> void:
		value = _value
		cut = _cut

# endregion


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	# todo: oh fuck what is this dependency
	return player.model.__velocity_by_input(input, delta)


func sync_with_prev_loco_anim(next_anim_correction: float = 0.0) -> float:
	var result_offset = -1
	# NOTE: Action is switched, but animator still treats an anim from prev action as "current" 
	#       (before current action hits set_anim_to_play)
	var prev_anim_progress = animator_manager.get_current_anim_effective_progress()
	var prev_anim = legs_sm.prev_action.anim
	var prev_l_leg_contact = prev_anim.get_marker_by_name(M.MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT)
	var next_l_leg_contact = anim.get_marker_by_name(M.MarkerName.LOCO_LOOP_L_LEG_FULL_CONTACT)
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


func __log_anim(blend_time, start_time_offset):
	print_.lsm_action_anim(action_name, anim.anim_name, legs_sm.prev_action.action_name, blend_time, start_time_offset)