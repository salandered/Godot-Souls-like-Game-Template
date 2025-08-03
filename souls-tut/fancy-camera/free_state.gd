extends CameraState
class_name FreeCameraState

@onready var fc: FancyCamera = $".."


# Tells our camera what to focus on
var look_at_: Node3D
var offset: Vector3


func initialise():
	offset = fc.nest.global_position - fc.mount.global_position
	look_at_ = fc.look_at_
	
	print("FreeCameraState ready()")
	print("		look_at_ ", look_at_)
	print("		offset ", offset)


func update(delta: float):
	# Imagine, the character moved. 
	# - First, we make the Focus Point the character. The core function is `rotate_offset`. 
	# - Then, we adjust Camera Mount and Camera Nest to mimic Focus movements, but we don't want to change the offset length, and we don't want to simply translate it.
	# - Then, in the end, we adjust camera position and the line of sight.
	_move_focus_point()
	_move_camera_mount()
	_move_camera(delta)


func _move_focus_point() -> void:
	var camera_focus_position := look_at_.global_position # look_at_ = CameraFocus
	var focus_point_position := fc.focus.global_position
	if not focus_point_position.is_equal_approx(camera_focus_position):
		var new_focus = lerp(focus_point_position, camera_focus_position, fc.FOLLOW_SPEED)
		_rotate_offset(new_focus)
		fc.focus.global_position = new_focus

func _rotate_offset(new_focus: Vector3) -> void:
	#  States from one offset to another after Focus Point movement. 
	#  To do it we count this angle and rotate the offset by the vertical axis. 
	#  Additional vars  with zero and Y coordinate is due to wanting only the angle of the projected horizontally picture 
	#  		and not the angle in 3D between these vectors. 
	#  Decider part is once again uses the cross product to decide if we want to rotate to the right or to the left.
	var new_focus_projected := Vector3(new_focus.x, 0, new_focus.z)
	var old_offset_projected := Vector3(-offset.x, 0, -offset.z)
	var center := fc.focus.global_position + offset
	var center_projected := Vector3(center.x, 0, center.z)

	var new_direction := new_focus_projected - center_projected
	var alpha := new_direction.angle_to(old_offset_projected)

	var decider = new_direction.cross(old_offset_projected)
	var signed_alpha: float = alpha if decider.y < 0 else -alpha
	offset = offset.rotated(Vector3.UP, signed_alpha)

func _move_camera_mount() -> void:
	var camera_focus_position: Vector3 = fc.player.camera_focus.global_position
	fc.mount.global_position = fc.mount.global_position.lerp(camera_focus_position, fc.FOLLOW_SPEED)
	fc.nest.global_position = fc.mount.global_position + offset

func _move_camera(delta: float) -> void:
	# alternative from chat.
	# @export var LERP_SPEED: float = 8.0
	# var camera_nest_position = fc.nest.global_position
	# var orig = fc.camera.global_transform.origin.lerp(camera_nest_position, delta * lerp_speed)
	# fc.camera.global_transform = Transform3D(fc.camera.global_transform.basis, orig)
	# fc.camera.look_at(fc.focus.global_position)
	# Working fair original 
	# if not fc.camera.position.is_equal_approx(fc.nest.position):
	# 	fc.camera.position = fc.nest.position
	# fc.camera.look_at(fc.focus.global_position)
	var from := fc.mount.global_position
	var to := fc.nest.global_position
	var space_state := fc.camera.get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [fc.player, fc.mount, fc.nest, fc.camera]
	query.collision_mask = fc.SPRING_ARM_COLLISION_MASK # define this in your FancyCamera if needed

	var result := space_state.intersect_ray(query)

	var final_pos := to

	if result:
		var hit_pos = result.position + result.normal * 0.05
		if (hit_pos - from).length_squared() < (to - from).length_squared():
			final_pos = hit_pos

	fc.camera.global_position = final_pos
	fc.camera.look_at(fc.focus.global_position)

	
func input_mouse_movement(d_x: float, d_y: float) -> void:
	# takes the Delta mouse movement and somehow counts a Delta angle from that movement length.
	# Then, we rotate offset vector by that angle using the correspondent axis.
	# Delta movements are very small, and `sin(Alpha) ~ Alpha`. 
	#    => divide by a thousand and multiply by a sensitivity number for the user to modify the sensitivity.
	# For the horizontal movement, it's always ok because the rotation axis is just a vertical axis.
	# The axis of vertical rotation is dynamic; we need to calculate it.
	#    - Use vector operation called Vector Cross Product (or Vector Crossing). 
	#			(Built-in way to get a vector which is perpendicular to two given vectors simultaneously.)
	#    - One of such vectors is the vertical axis, and the other one is just our offset.
	offset = offset.rotated(Vector3.UP, -d_x * fc.HOR_SENSE * 0.001)

	var axis := offset.cross(Vector3.UP).normalized()
	var angle = d_y * fc.VER_SENSE * 0.001
	var new_offset = offset.rotated(axis, angle)
	var new_offset_angle = new_offset.angle_to(Vector3.UP)
	if new_offset_angle > fc.MIN_VERTICAL_ANGLE and new_offset_angle < fc.MAX_VERTICAL_ANGLE:
		offset = new_offset

func input_target_lock():
	var found_target = fc.player.model.area_awareness.find_target()
	if found_target:
		fc.locked_target = found_target
		print("		fc.found_target ", fc.locked_target)
		fc.current_state = fc.locked_camera
		fc.locked_camera.look_at_ = fc.locked_target.look_at_point
		
		# fc.locked_camera.offset = fc.nest.global_position - fc.mount.global_position
		fc.locked_camera.offset = offset
		fc.locked_camera.target_offset = _calc_locked_offset(found_target, offset)
		fc.locked_camera.offset_transition_t = 0.0

		print("LOCK SUCCESFULL")
	else:
		print("xLOCK NOT")

func _calc_locked_offset(locked_target: Node3D, offset_: Vector3) -> Vector3:
	var new_focus = locked_target.look_at_point.global_position
	var new_focus_projected := Vector3(new_focus.x, 0, new_focus.z)
	var center_projected = fc.player.camera_focus.global_position
	center_projected.y = 0
	var offset_xz_length := sqrt(offset_.x * offset_.x + offset_.z * offset_.z)
	var new_offset = (center_projected - new_focus_projected).normalized() * offset_xz_length
	new_offset.y = offset_.y
	return new_offset
