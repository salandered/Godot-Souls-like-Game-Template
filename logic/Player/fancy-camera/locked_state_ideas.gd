extends CameraState
# class_name LockedCameraState

var look_at_: Node3D
var offset: Vector3
var offset_transition_t := 0.0

var offset_basis: Vector3 # captured arm at the moment of lock
var _blending := false # true while offset_transition_t < 1.0
var _just_locked := false # first-frame nest freeze (prevents base-point rebase)


func _ready():
	look_at_ = fc.look_at_
	print("LockedCameraState ready()")
	print("		look_at_ ", look_at_)


func update(delta: float) -> void:
	# 1) Focus step (keep your existing code)
	_move_focus_point() # whatever name you use for the chest→target focus smoothing

	# 2) Rotate every frame; blend from the captured basis
	var desired_rotated := _calc_lock_offset_from(offset_basis)
	if _blending:
		offset = offset_basis.lerp(desired_rotated, offset_transition_t)
		offset_transition_t = min(1.0, offset_transition_t + delta / fc.OFFSET_BLEND_DURATION_ON_LOCK)
		if offset_transition_t >= 1.0:
			_blending = false
			# Snap basis to the achieved offset to avoid an end-of-ease seam
			offset_basis = offset
	else:
		# After blend: continue rotating smoothly, preserving current length/Y
		offset = _calc_lock_offset_from(offset)
	_move_camera_mount() # Keep mount smooth movement
	_move_camera_nest() # Keep nest smooth movement
	# _adjust_camera_aim() # experiment for future
	_move_camera()
	_check_distance()

func _move_focus_point() -> void:
	fc.focus.global_position = lerp_position_(fc.focus, look_at_, fc.LOCKED_FOCUS_TARGET_WEIGHT)


func _calc_lock_offset_from(arm: Vector3) -> Vector3:
	# Keep Y and length, only rotate XZ so the camera sits behind center→target.
	var center := fc.player.camera_focus.global_position
	var target = look_at_.global_position
	var dir = (center - target)
	dir.y = 0.0
	if dir.length() < 0.0001:
		return arm
	dir = dir.normalized()
	
	# Consider: avoid sqrt twice / normalize zero: var xz_len := Vector2(arm.x, arm.z).length(); if xz_len <= 0.00001: return arm
	var xz_len := sqrt(arm.x * arm.x + arm.z * arm.z)
	var rotated := Vector3(dir.x, 0.0, dir.z) * xz_len
	rotated.y = arm.y
	return rotated


func _move_camera_mount() -> void:
	fc.mount.global_position = lerp_position_(fc.mount, fc.player.camera_focus, fc.LOCKED_MOUNT_CHEST_WEIGHT)

func _move_camera_nest() -> void:
	var desired := fc.mount.global_position + offset
	if _just_locked:
		# Prevent base-point rebase on the first locked frame
		fc.nest.global_position = desired
		_just_locked = false
	else:
		fc.nest.global_position = lerp_position_(fc.nest, desired, fc.LOCKED_NEST_MOUNT_WEIGHT)

func _rotate_offset_locked(new_focus: Vector3) -> void:
	var _offset = offset
	
	var new_focus_projected := Vector3(new_focus.x, 0, new_focus.z)
	var camera_focus_pos = fc.player.camera_focus.global_position
	
	var center_projected := Vector3(camera_focus_pos.x, 0, camera_focus_pos.z)

	var offset_xz_length := sqrt(_offset.x * _offset.x + _offset.z * _offset.z)
	var new_offset := (center_projected - new_focus_projected).normalized() * offset_xz_length
	new_offset.y = offset.y
	offset = new_offset

func _move_camera() -> void:
	var mount_pos := fc.mount.global_position
	var nest_pos := fc.nest.global_position
	var space_state := fc.camera.get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(mount_pos, nest_pos)
	query.exclude = [fc.player, fc.mount, fc.nest, fc.camera]
	query.collision_mask = fc.SPRING_ARM_COLLISION_MASK

	var result = space_state.intersect_ray(query)

	var final_pos := nest_pos
	if result:
		var hit_pos = result.position + result.normal * 0.05
		var max_dist = (nest_pos - mount_pos).length()
		var actual_dist = (hit_pos - mount_pos).length()
		if actual_dist < max_dist:
			final_pos = hit_pos

	fc.camera.global_position = final_pos
	u.safe_look_at(fc.camera, fc.focus.global_position)


func _check_distance() -> void:
	# checks if the distance between the player and target is too big and drops the target if triggered
	if fc.player.model.area_awareness.camera_focus_further_than(fc.locked_target, fc.TARGET_DROP_DISTANCE_SQUARED):
		# print("dropping ", distance, " ", TARGET_DROP_DISTANCE_SQUARED)
		_drop_target()

func check_relevance():
	_drop_target()

func _drop_target() -> void:
	print("DROP started")

	var mount_pos := fc.mount.global_position
	var cam_pos := fc.camera.global_position
	var live_arm := cam_pos - mount_pos

	fc.free_camera.look_at_ = fc.player.camera_focus
	fc.free_camera.offset = live_arm
	fc.free_camera._current_len = live_arm.length()

	fc.free_camera._unlock_freeze_frames = fc.FREEZE_FRAMES_ON_UNLOCK

	fc.current_state = fc.free_camera
	fc.locked_target = fc.nest
	print("DROP ended")

	
func input_mouse_movement(d_x: float, d_y: float) -> void:
	# offset = offset.rotated(Vector3.UP, -d_x * fc.HOR_SENSE * 0.001)
	# var axis := offset.cross(Vector3.UP).normalized()
	# var angle = d_y * fc.VER_SENSE * 0.001
	# var new_offset = offset.rotated(axis, angle)
	# var new_offset_angle = new_offset.angle_to(Vector3.UP)
	# if new_offset_angle > fc.MIN_VERTICAL_ANGLE and new_offset_angle < fc.MAX_VERTICAL_ANGLE:
	# 	offset = new_offset
	pass
	# Ignore horizontal while locked; vertical only.
	# if delta_y == 0.0:
	# 	return

	# var chest_pos := fc.player.camera_focus.global_position
	# var target_pos := look_at_.global_position

	# # Build a "right" axis from chest→target (yaw stays target-driven).
	# var chest_to_target := target_pos - chest_pos
	# var right_axis := chest_to_target.cross(Vector3.UP)
	# if right_axis.length() < 0.0001:
	# 	# Degenerate: target straight above/below. Fall back to camera's local right.
	# 	right_axis = offset.cross(Vector3.UP)
	# if right_axis.length() < 0.0001:
	# 	return
	# right_axis = right_axis.normalized()

	# # Rotate offset around that right axis (distance preserved).
	# var pitch_angle := -delta_y * fc.VER_SENSE * 0.001
	# var new_offset := offset.rotated(right_axis, pitch_angle)

	# # Clamp vertical as usual.
	# var angle_to_up := new_offset.angle_to(Vector3.UP)
	# if angle_to_up >= fc.MIN_VERTICAL_ANGLE and angle_to_up <= fc.MAX_VERTICAL_ANGLE:
	# 	offset = new_offset


# region: experimental
# func _adjust_camera_aim() -> void:
# 	# NEW: Adjust the focus point to ensure camera looks through chest to target
# 	var chest_pos = fc.player.camera_focus.global_position
# 	var target_pos = look_at_.global_position
	
# 	# Calculate the ideal focus position that makes the camera look through chest to target
# 	# This creates a line: camera -> chest -> target
# 	var camera_to_chest = chest_pos - fc.camera.global_position
# 	var chest_to_target = target_pos - chest_pos
	
# 	# The ideal focus point is along the chest_to_target line, but at a distance
# 	# that ensures the camera frames both player and target well
# 	var ideal_focus_distance = chest_to_target.length() * 0.5 # Adjust this factor as needed
# 	var ideal_focus_pos = chest_pos + chest_to_target.normalized() * ideal_focus_distance
	
# 	# Smoothly move the focus point toward the ideal position
# 	fc.focus.global_position = lerp_position_(fc.focus,	ideal_focus_pos, fc.FOCUS_FOLLOWING_WEIGHT)
# 	)
# endregion


	# yaw around global up
	# lock_offset = lock_offset.rotated(Vector3.UP, -d_x * fc.FREE_HOR_SENSE * 0.001)

	# # pitch around local right (perpendicular to UP and current offset)
	# var axis := lock_offset.cross(Vector3.UP).normalized()
	# var angle := d_y * fc.FREE_VER_SENSE * 0.001
	# var candidate := lock_offset.rotated(axis, angle)
	# var to_up := candidate.angle_to(Vector3.UP)
	# if to_up > fc.MIN_VERTICAL_ANGLE and to_up < fc.MAX_VERTICAL_ANGLE:
	# 	lock_offset = candidate


	# SUGGESTED WAY
	# var prev_lock_off_xz := Vector3(lock_offset.x, 0.0, lock_offset.z).normalized()
	# var yaw_err_rad := atan2(prev_lock_off_xz.cross(desired_xz).y, prev_lock_off_xz.dot(desired_xz))
	# var max_step_rad := deg_to_rad(fc.LOCKED_MAX_YAW_SPEED_DEG_PER_SEC) * delta
	# var step_rad = clamp(yaw_err_rad, -max_step_rad, max_step_rad)
	# lock_offset = lock_offset.rotated(Vector3.UP, step_rad)


	#####################################


# try for last locked state


# 	1) Tunables (add at top)
# const MIN_LOCK_RADIUS := 0.05
# const LOCK_YAW_DEG_PER_SEC := 540.0 # cap post-blend yaw speed; 360–720 feels good

# 2) Stronger radius guard on lock (replace your 0.05 literal)
# blend_start_horizontal_len = current_offset_xz.length()
# if blend_start_horizontal_len < MIN_LOCK_RADIUS:
# 	blend_start_horizontal_len = MIN_LOCK_RADIUS

# 3) Post-blend yaw cap (replace your “DIRECT ASSIGNMENT” else-branch)

# This avoids 1-frame twitches if target/mount jump.

# else:
# 	# --- RESPONSIVE LOCK (CAPPED YAW STEP) ---
# 	var desired_yaw := desired_dir_xz.angle()
# 	var current_yaw := Vector2(lock_offset.x, lock_offset.z).angle()
# 	var yaw_delta := wrapf(desired_yaw - current_yaw, -PI, PI)

# 	var max_step := deg_to_rad(LOCK_YAW_DEG_PER_SEC) * delta
# 	var step := clamp(yaw_delta, -max_step, max_step)
# 	var yaw_new := current_yaw + step

# 	var len_h := Vector2(lock_offset.x, lock_offset.z).length()
# 	if len_h < MIN_LOCK_RADIUS: len_h = MIN_LOCK_RADIUS

# 	var final_xz := Vector2.from_angle(yaw_new) * len_h
# 	lock_offset.x = final_xz.x
# 	lock_offset.z = final_xz.y