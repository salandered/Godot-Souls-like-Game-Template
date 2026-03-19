extends CameraState
class_name FreeCameraState


var chest: Node3D # CameraFocus node while not locked
var free_boom: Vector3


func switch_from_locked():
	__log_("switch_from_locked started")
	chest = fc.player.camera_focus
	var restored_boom := fc.socket.global_position - fc.pivot.global_position
	free_boom = restored_boom.normalized() * free_boom.length()
	# tried: free_boom = fc.socket.global_position - fc.pivot.global_position
	# another option against snapping to try
	# _current_len = (fc.socket.global_position - fc.pivot.global_position).length()
	
	__log_("switch_from_locked ended")


func update(delta: float) -> void:
	var prev_aim_pos := fc.aim.global_position

	_move_aim(delta) # Aim follows player's chest

	_rotate_boom(prev_aim_pos, fc.aim.global_position)

	_move_camera_pivot(delta)
	_move_camera_socket(delta)

	fc.camera_movement.move_camera(delta)

	# __log_("[FREE UPD post", FrameUtils.sfr(), "]", fc.__dbg_main_info())


func _move_aim(delta: float) -> void:
	if not fc.aim.global_position.is_equal_approx(chest.global_position):
		var adjusted_weight = fc.FREE_AIM_CHEST_WEIGHT * (delta * 60.0)
		adjusted_weight = clamp(adjusted_weight, 0.0, 1.0)
	
		fc.aim.global_position = lerp_position_(fc.aim, chest, adjusted_weight)


# region: old docs
#  rotating boom after Aim movement
#  count the angle and rotate free_boom by the vertical axis. 
#  Additional vars with zero and Y coordinate is due to wanting only the angle of the projected horizontally picture 
#  		and not the angle in 3D between these vectors. 
#  Decider part uses the cross product to decide if we want to rotate to the right or left.
# endregion
func _rotate_boom(prev_aim_pos: Vector3, new_aim_pos: Vector3) -> void:
	var new_aim_xz := Vector3(new_aim_pos.x, 0, new_aim_pos.z)
	var old_boom_xz := Vector3(-free_boom.x, 0, -free_boom.z)

	# if prev_aim_pos is changed to new, then no circular movement
	var center := prev_aim_pos + free_boom
	var center_xz := Vector3(center.x, 0, center.z)

	var new_direction := new_aim_xz - center_xz
	var alpha := new_direction.angle_to(old_boom_xz)

	var decider := new_direction.cross(old_boom_xz)
	var signed_alpha: float = alpha if decider.y < 0 else -alpha

	# TODO
	# DANGER: seems like boom = boom.rotated is a bad practice: Rot error will be accumulating.
	free_boom = free_boom.rotated(Vector3.UP, signed_alpha)


func _move_camera_pivot(delta: float) -> void:
	var adjusted_weight = fc.FREE_SOCKET_CHEST_WEIGHT * (delta * 60.0)
	adjusted_weight = clamp(adjusted_weight, 0.0, 1.0)
	fc.pivot.global_position = lerp_position_(
		fc.pivot,
		fc.player.camera_focus,
		adjusted_weight
	)

func _move_camera_socket(delta: float) -> void:
	var adjusted_weight = fc.FREE_SOCKET_PIVOT_WEIGHT * (delta * 60.0)
	adjusted_weight = clamp(adjusted_weight, 0.0, 1.0)
	fc.socket.global_position = lerp_position_(
		fc.socket,
		fc.pivot.global_position + free_boom,
		adjusted_weight
	)


# region: old docs
	# take the Delta 🖱️ movement and calculates a Delta angle from that movement length.
	# then rotate free_boom vector by that angle using the correspondent axis.
	# Delta movement is small => sin(Alpha) ~ Alpha. 
	#    => divide by a thousand and multiply by a sensitivity number
	# For the horizontal movement, it's always ok because the rotation axis is a vertical axis.
	# The axis of vertical rotation is dynamic; we need to calculate it.
	#    - use vector operation Vector Cross Product (or Vector Crossing). 
	#			(Built-in way to get a vector which is perpendicular to two given vectors simultaneously.)
	#    - One of such vectors is the vertical axis, and the other one is our free_boom.
func input_mouse_movement(d_x: float, d_y: float) -> void:
	# HORIZONTAL
	free_boom = free_boom.rotated(Vector3.UP, -d_x * fc.mouse_sense.x_sense * 0.001)

	# VERTICAL 
	free_boom = vertical_mouse_movement(d_x, d_y, free_boom)

	# TODO
	# DANGER: seems like boom = boom.rotated is a bad practice: Rot error will be accumulating.
