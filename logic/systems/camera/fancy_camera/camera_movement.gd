extends Node
class_name CameraMovement

# Solves collisions and adjusts camera movement.
# Common idea: 
# 	 - states do what they want with placing camera nodes (pivot, socket, etc)
#    - here we take restrictions into account and place main camera.
# Should change cam length, may be slide direction and where to look. 
# Should not change angle of the camera boom.


@onready var fc: FancyCamera = $".."

var _current_len: float
var _default_len: float


func _exclude_colliders() -> Array:
	return [fc.player, fc.pivot, fc.socket, fc.camera]


## If there are no collisions
func _just_follow_socket() -> void:
	fc.camera.global_position = fc.socket.global_position
	tu.safe_look_at(fc.camera, fc.aim.global_position)

	# NOTE that was this way, but big snapping on unlocking:
	# final_pos = from + arm_dir * _current_len
	# fc.camera.global_position = final_pos
	# tu.safe_look_at(fc.camera, fc.aim.global_position)
	
	
func move_camera(delta: float) -> void:
	if not fc.__dev_camera_coll:
		_just_follow_socket()
		return

	var from := fc.pivot.global_position
	var to := fc.socket.global_position
	var arm_dir := (to - from).normalized()
	var desired_len := (to - from).length()
	var target_len: float = min(desired_len, _default_len)
	var final_pos: Vector3

	var min_hit_len := fc.camera_movement._calc_min_hit_len_via_raycasts(arm_dir, from, to, desired_len)

	# apply collision offset along the arm direction
	if min_hit_len < desired_len:
		target_len = min(min_hit_len - fc.COL_OFFSET, _default_len)

	# asymmetric smoothing (contract now, expand smoothly)
	if target_len < _current_len:
		_current_len = target_len # instant contract (A/C)
	else:
		var k := 1.0 - exp(-delta / fc.COL_EXPAND_TIME) # smooth grow (B)
		var step := (target_len - _current_len) * k
		var cap := fc.COL_MAX_EXPAND_SPEED * delta
		if step > cap:
			step = cap
		_current_len += step

	# place camera using the smoothed length
	final_pos = from + arm_dir * _current_len
	
	# final check if we clip through geometry
	if fc.camera_movement._check_camera_penetration(final_pos):
		final_pos = fc.camera_movement._resolve_penetration(from, final_pos, arm_dir)
	
	fc.camera.global_position = final_pos
	tu.safe_look_at(fc.camera, fc.aim.global_position)


func _calc_min_hit_len_via_raycasts(arm_dir: Vector3, from: Vector3, to: Vector3, desired_len: float) -> float:
	# Uses multiple raycasts with offsets perpendicular to arm direction
	# Builds a local frame perpendicular to the arm (so boom rotate with the arm)
	var space_state := fc.camera.get_world_3d().direct_space_state
	
	var right_axis := arm_dir.cross(Vector3.UP)
	if right_axis.length_squared() < 1e-4:
		right_axis = arm_dir.cross(Vector3.FORWARD)
	right_axis = right_axis.normalized()
	var up_axis := right_axis.cross(arm_dir).normalized()

	var ray_offsets := [
		Vector3.ZERO,
		right_axis * fc.COLLISION_CAM_RADIUS,
		- right_axis * fc.COLLISION_CAM_RADIUS,
		up_axis * fc.COLLISION_CAM_RADIUS,
		- up_axis * fc.COLLISION_CAM_RADIUS,
	]
	
	var min_hit_len := desired_len
	
	for offset_vec: Vector3 in ray_offsets:
		var ray_from := from + offset_vec
		var ray_to := to + offset_vec
		
		var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
		query.exclude = _exclude_colliders()
		query.collision_mask = fc.SPRING_ARM_COLLISION_MASK
		
		var result := space_state.intersect_ray(query)
		if result:
			# instead of offsetting by normal, calculate distance along arm
			# handles grazing angles better 
			# (Grazing angle is defined as the angle formed between the beam axis and the surface at which the measurement is taken)
			var hit_vec = result.position - from
			var hit_dist_along_arm = hit_vec.dot(arm_dir)
			min_hit_len = min(min_hit_len, hit_dist_along_arm)
	
	return min_hit_len


func _check_camera_penetration(camera_pos: Vector3) -> bool:
	var space_state := fc.camera.get_world_3d().direct_space_state
	
	# small sphere cast to check if camera would be inside geometry
	var shape := SphereShape3D.new()
	shape.radius = 0.3 # Camera volume radius # todo - magic constant
	
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), camera_pos)
	params.collision_mask = fc.SPRING_ARM_COLLISION_MASK
	params.exclude = _exclude_colliders()
	
	var results := space_state.intersect_shape(params, 1)
	return results.size() > 0


func _resolve_penetration(from: Vector3, camera_pos: Vector3, direction: Vector3) -> Vector3:
	var space_state := fc.camera.get_world_3d().direct_space_state
	
	# cast a ray to find a safe position
	var query := PhysicsRayQueryParameters3D.create(from, camera_pos)
	query.exclude = _exclude_colliders()
	query.collision_mask = fc.SPRING_ARM_COLLISION_MASK
	
	var result := space_state.intersect_ray(query)
	if result:
		# move camera to the collision point with a safe offset
		return result.position + result.normal * 0.3 # todo - magic constant
	
	return camera_pos # fallback to original position
