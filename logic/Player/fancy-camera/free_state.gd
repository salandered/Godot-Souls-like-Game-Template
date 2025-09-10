extends CameraState
class_name FreeCameraState

@onready var fc: FancyCamera = $".."


# Tells our camera what to focus on
var look_at_: Node3D # CameraFocus node
var offset: Vector3

@export_group("Camera distance smoothing")
@export var expand_time: float = 0.35 # how fast to float back to default
@export var max_expand_speed: float = 12.0

var _current_len: float
var _default_len: float


func initialise():
	offset = fc.nest.global_position - fc.mount.global_position
	look_at_ = fc.look_at_
	fc.camera.global_position = fc.look_at_.global_position + offset

	_default_len = offset.length()
	_current_len = _default_len
	
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

# @export_group("Camera Collision")
# @export var camera_radius: float = 0.3
# @export var collision_offset: float = 0.2
@export var camera_radius: float = 0.15 # try 0.25–0.35


func _move_camera(delta: float) -> void:
	var from := fc.mount.global_position
	var to := fc.nest.global_position
	var arm_dir := (to - from).normalized()
	var desired_len := (to - from).length()
	var target_len: float = min(desired_len, _default_len)
	var final_pos: Vector3

	if not fc.__dev_camera_cols:
		final_pos = from + arm_dir * _current_len
		fc.camera.global_position = final_pos
		u.safe_look_at(fc.camera, fc.focus.global_position)
		return

	var space_state := fc.camera.get_world_3d().direct_space_state
	
	# Calculate basis vectors perpendicular to the arm direction
	# This ensures offsets are always relative to the camera's orientation
	var right = Vector3.UP.cross(arm_dir).normalized()
	if right.length() < 0.1: # Handle case when arm_dir is parallel to UP
		right = Vector3.RIGHT.cross(arm_dir).normalized()
	var up = arm_dir.cross(right).normalized()
	
	# Use multiple raycasts with offsets perpendicular to arm direction
	# Build a local frame perpendicular to the arm (so offsets rotate with the arm)
	var right_axis := arm_dir.cross(Vector3.UP)
	if right_axis.length_squared() < 1e-4:
		right_axis = arm_dir.cross(Vector3.FORWARD)
	right_axis = right_axis.normalized()
	var up_axis := right_axis.cross(arm_dir).normalized()

	var collision_offset := 0.2 # keep your old margin if you like it
	var ray_offsets := [
		Vector3.ZERO,
		right_axis * camera_radius,
		- right_axis * camera_radius,
		up_axis * camera_radius,
		- up_axis * camera_radius,
	]
	
	var min_hit_len = desired_len
	
	for offset_vec in ray_offsets:
		var ray_from = from + offset_vec
		var ray_to = to + offset_vec
		
		var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
		query.exclude = [fc.player, fc.mount, fc.nest, fc.camera]
		query.collision_mask = fc.SPRING_ARM_COLLISION_MASK
		
		var result := space_state.intersect_ray(query)
		if result:
			# Instead of offsetting by normal, calculate distance along arm
			# This handles grazing angles better
			var hit_vec = result.position - from
			var hit_dist_along_arm = hit_vec.dot(arm_dir)
			min_hit_len = min(min_hit_len, hit_dist_along_arm)
	
	# Apply collision offset along the arm direction
	if min_hit_len < desired_len:
		target_len = min(min_hit_len - collision_offset, _default_len)
	
	# --- asymmetric smoothing (contract now, expand smoothly)
	if target_len < _current_len:
		_current_len = target_len # instant contract (A/C)
	else:
		var k := 1.0 - exp(-delta / expand_time) # smooth grow (B)
		var step := (target_len - _current_len) * k
		var cap := max_expand_speed * delta
		if step > cap:
			step = cap
		_current_len += step

	# --- place camera using the smoothed length
	final_pos = from + arm_dir * _current_len
	
	# Final check to ensure we're not clipping through geometry
	if _check_camera_penetration(final_pos):
		final_pos = _resolve_penetration(from, final_pos, arm_dir)
	
	fc.camera.global_position = final_pos
	u.safe_look_at(fc.camera, fc.focus.global_position)

func _check_camera_penetration(camera_pos: Vector3) -> bool:
	var space_state = fc.camera.get_world_3d().direct_space_state
	
	# Use a small sphere cast to check if camera would be inside geometry
	var shape = SphereShape3D.new()
	shape.radius = 0.3 # Camera volume radius
	
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), camera_pos)
	params.collision_mask = fc.SPRING_ARM_COLLISION_MASK
	params.exclude = [fc.player, fc.mount, fc.nest, fc.camera]
	
	var results = space_state.intersect_shape(params, 1)
	return results.size() > 0

func _resolve_penetration(from: Vector3, camera_pos: Vector3, direction: Vector3) -> Vector3:
	var space_state = fc.camera.get_world_3d().direct_space_state
	
	# Cast a ray to find a safe position
	var query := PhysicsRayQueryParameters3D.create(from, camera_pos)
	query.exclude = [fc.player, fc.mount, fc.nest, fc.camera]
	query.collision_mask = fc.SPRING_ARM_COLLISION_MASK
	
	var result := space_state.intersect_ray(query)
	if result:
		# Move camera to the collision point with a safe offset
		return result.position + result.normal * 0.3
	
	return camera_pos # Fallback to original position

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
