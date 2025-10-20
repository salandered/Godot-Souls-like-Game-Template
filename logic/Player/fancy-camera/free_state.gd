extends CameraState
class_name FreeCameraState


var chest: Node3D # CameraFocus node while not locked
var free_offset: Vector3


func switch_from_locked():
	print_.fancy_cam(state_name, "DROP started")
	chest = fc.player.camera_focus
	var restored_offset := fc.nest.global_position - fc.mount.global_position
	free_offset = restored_offset.normalized() * free_offset.length()
	# tried: free_offset = fc.nest.global_position - fc.mount.global_position
	# another option against snapping to try
	# _current_len = (fc.nest.global_position - fc.mount.global_position).length()
	
	print_.fancy_cam(state_name, "DROP ended")


func update(delta: float):
	var prev_focus_pos := fc.focus.global_position

	_move_focus_point() # Focus Point follows player's chest

	_rotate_offset(prev_focus_pos, fc.focus.global_position)

	_move_camera_mount()
	_move_camera_nest()

	fc.camera_movement.move_camera(delta)

	# print_.fancy_cam("[~~FREE UPD post", u.fr(), "]", fc.__dbg_main_info())


func _move_focus_point() -> void:
	if not fc.focus.global_position.is_equal_approx(chest.global_position):
		fc.focus.global_position = lerp_position_(fc.focus, chest, fc.FREE_FOCUS_CHEST_WEIGHT)


# region: old docs
#  from one free_offset to another after Focus Point movement. 
#  To do it we count this angle and rotate the free_offset by the vertical axis. 
#  Additional vars with zero and Y coordinate is due to wanting only the angle of the projected horizontally picture 
#  		and not the angle in 3D between these vectors. 
#  Decider part is once again uses the cross product to decide if we want to rotate to the right or to the left.
# endregion
func _rotate_offset(prev_focus_pos: Vector3, new_focus_pos: Vector3) -> void:
	var new_focus_xz := Vector3(new_focus_pos.x, 0, new_focus_pos.z)
	var old_offset_xz := Vector3(-free_offset.x, 0, -free_offset.z)

	# if prev_focus_pos is changed to new, then no circular movement
	var center := prev_focus_pos + free_offset
	var center_xz := Vector3(center.x, 0, center.z)

	var new_direction := new_focus_xz - center_xz
	var alpha := new_direction.angle_to(old_offset_xz)

	var decider := new_direction.cross(old_offset_xz)
	var signed_alpha: float = alpha if decider.y < 0 else -alpha
	free_offset = free_offset.rotated(Vector3.UP, signed_alpha)


func _move_camera_mount() -> void:
	fc.mount.global_position = lerp_position_(fc.mount, fc.player.camera_focus, fc.FREE_MOUNT_CHEST_WEIGHT)

func _move_camera_nest() -> void:
	fc.nest.global_position = lerp_position_(fc.nest, fc.mount.global_position + free_offset, fc.FREE_NEST_MOUNT_WEIGHT)


# region: old docs
	# take the Delta 🖱️ movement and somehow counts a Delta angle from that movement length.
	# then rotate free_offset vector by that angle using the correspondent axis.
	# Delta movement is small => sin(Alpha) ~ Alpha. 
	#    => divide by a thousand and multiply by a sensitivity number
	# For the horizontal movement, it's always ok because the rotation axis is a vertical axis.
	# The axis of vertical rotation is dynamic; we need to calculate it.
	#    - use vector operation Vector Cross Product (or Vector Crossing). 
	#			(Built-in way to get a vector which is perpendicular to two given vectors simultaneously.)
	#    - One of such vectors is the vertical axis, and the other one is our free_offset.
func input_mouse_movement(d_x: float, d_y: float) -> void:
	# HORIZONTAL
	free_offset = free_offset.rotated(Vector3.UP, -d_x * fc.HOR_SENSE * 0.001)

	# VERTICAL 
	free_offset = vertical_mouse_movement(d_x, d_y, free_offset)
