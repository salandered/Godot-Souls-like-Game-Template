@abstract
class_name CameraState
extends Node


var state_name: String

var fc: FancyCamera


@abstract func update(delta: float) -> void


@abstract func input_mouse_movement(d_x: float, d_y: float)


func vertical_mouse_movement(d_x: float, d_y: float, offset: Vector3) -> Vector3:
	var min_vertical_angle: float
	var max_vertical_angle: float
	var vertical_sense: float
	if fc.current_state == fc.free_state:
		min_vertical_angle = fc.MIN_VERTICAL_ANGLE
		max_vertical_angle = fc.MAX_VERTICAL_ANGLE
		vertical_sense = fc.mouse_sense.y_sense
	else: # lock state
		# TODO: no extensive testing was made when lock using bigger free state guards than lock state allows
		min_vertical_angle = fc.MIN_VERTICAL_ANGLE + 0.3
		max_vertical_angle = fc.MAX_VERTICAL_ANGLE - 0.3
		vertical_sense = fc.mouse_sense.locked_y_sense

	var vertical_axis := offset.cross(Vector3.UP)
	var axis_len := vertical_axis.length()
	
	if axis_len < Constants.EPSILON_5: # axis degenerate near straight-up/down — ignoring this frame
		__log_(em.warn_mb, "vert mouse move skip frame")
		return offset

	vertical_axis = vertical_axis / axis_len
	var rot_angle := d_y * vertical_sense * 0.001
	
	# current theta = angle to UP (MIN/MAX space)
	var theta_now := acos(clampf(offset.normalized().dot(Vector3.UP), -1.0, 1.0))

	# Predict result of the raw input
	var predicted := offset.rotated(vertical_axis, rot_angle)
	var theta_pred := acos(clampf(predicted.normalized().dot(Vector3.UP), -1.0, 1.0))

	# Clamp the *target theta* (not the rot angle)
	var theta_target := clampf(theta_pred, min_vertical_angle + fc.VERT_EPS, max_vertical_angle - fc.VERT_EPS)

	if abs(theta_pred - theta_target) < Constants.EPSILON_7:
		offset = predicted # no breach — take full step
	else:
		# breach: scale the rotation proportionally so land on the rail
		var denom := theta_pred - theta_now
		if abs(denom) > Constants.EPSILON_9: # why so many different epsilons ...
			var scale := clampf((theta_target - theta_now) / denom, 0.0, 1.0)
			# TODO
			# DANGER: seems like offset = offset.rotated is a bad practice: Rot error will be accumulating.
			offset = offset.rotated(vertical_axis, rot_angle * scale)
		# else: # denom ~ 0 means input had ~no theta change; do nothing this frame
			# __log_("vert mouse move skip frame")
	
	# DEV
	# var theta_after := acos(clamp(free_offset.normalized().dot(Vector3.UP), -1.0, 1.0))
	# print_.fancy_cam("[vertSAT] θ_now=", rad_to_deg(theta_now),
	# 	" θ_pred=", rad_to_deg(theta_pred),
	# 	" θ_target=", rad_to_deg(theta_target),
	# 	" θ_after=", rad_to_deg(theta_after))
	return offset


func lerp_position_(from: Variant, to: Variant, weight: float) -> Vector3:
	if from is not Node3D and from is not Vector3:
		__log_error("lerp_position_ 'from' type error", from)
		return Vector3.ZERO
	if to is not Node3D and to is not Vector3:
		__log_error("lerp_position_ 'to' type error", to)
		return Vector3.ZERO

	var from_pos: Vector3
	var to_pos: Vector3

	if from is Node3D:
		from_pos = from.global_position
	else:
		from_pos = from

	if to is Node3D:
		to_pos = to.global_position
	else:
		to_pos = to

	return from_pos.lerp(to_pos, weight)


# region __LOGS

func __log_(...parts: Array):
	fc.__log_(state_name, pp.list_(parts))

func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	fc.__log_warn(what, where + " " + state_name, fallback, pp.list_(context))


# endregion
