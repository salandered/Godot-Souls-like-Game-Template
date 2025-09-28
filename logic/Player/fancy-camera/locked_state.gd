extends CameraState
class_name LockedCameraState

var target: Node3D
var lock_offset: Vector3

var is_blending := false
var blend_timer := 0.0
var blend_duration := 0.4 # 0.3-0.6 seconds (shorter = snappier lock, longer = smoother)

# State captured on the frame of locking, to anchor the blend
var blend_start_yaw_rad := 0.0
var blend_start_horizontal_len := 0.0


func switch_from_free(found_target: Node):
	target = found_target.look_at_point

	# --- "Seed from reality, not state." ---
	# Capture the true offset at the moment of locking to prevent any jump.
	lock_offset = fc.nest.global_position - fc.mount.global_position
	# lock_offset = fc.camera.global_position - fc.mount.global_position
	
	var cam_minus_mount := fc.camera.global_position - fc.mount.global_position
	var err := (cam_minus_mount - lock_offset).length()
	# print_.fancy_cam("[~~ lock: err_to_offset_on_entry=", err)
	# --- Anchor the blend ---
	# Store the initial conditions. The blend will always be from this
	# fixed start-point to the moving end-point.
	var current_offset_xz := Vector2(lock_offset.x, lock_offset.z)
	blend_start_yaw_rad = current_offset_xz.angle()

	blend_start_horizontal_len = current_offset_xz.length()
	if blend_start_horizontal_len < 0.05: # optional to try
		blend_start_horizontal_len = 0.05

	is_blending = true
	blend_timer = 0.0
	
	# print_.fancy_cam("[~~LOCK ENT post ", u.fr(), "]", fc.__dbg_main_info(), " target=", str(target))

func update(delta: float) -> void:
	# print_.fancy_cam("[~~LOCK UPD pre ", u.fr(), "]", fc.__dbg_main_info())
	# move the anchor points
	_move_focus_point()
	_move_camera_mount()
	
	# calculate the rotation based on their new positions
	_rotate_offset_locked(delta)
	
	# position the camera elements
	_move_camera_nest()
	fc.camera_movement.move_camera(delta)

	# TODO TODO: return check_distance
	# TODO: not only distance, but line of sight? 
	# 		what if enemy falls, we are doomed to look at floor

	# print_.fancy_cam("[~~LOCK UPD post ", u.fr(), "]", fc.__Cvec(), fc.__CM(), fc.__CF())


func _move_focus_point() -> void:
	fc.focus.global_position = lerp_position_(fc.focus, target, fc.LOCKED_FOCUS_TARGET_WEIGHT)

func _move_camera_mount() -> void:
	fc.mount.global_position = lerp_position_(fc.mount, fc.player.camera_focus, fc.LOCKED_MOUNT_CHEST_WEIGHT)

func _move_camera_nest() -> void:
	fc.nest.global_position = lerp_position_(fc.nest, fc.mount.global_position + lock_offset, fc.LOCKED_NEST_MOUNT_WEIGHT)


func _rotate_offset_locked(delta: float) -> void:
	var _off_before := lock_offset

	# desired direction is from the target to the camera's direct anchor (the mount).
	var desired_dir_xz := Vector2(fc.mount.global_position.x - target.global_position.x, fc.mount.global_position.z - target.global_position.z).normalized()

	# against zero radius (player is directly on top of the target or something)
	if desired_dir_xz.length_squared() < 0.0001: return

	var desired_yaw := desired_dir_xz.angle()
	var current_yaw := Vector2(_off_before.x, _off_before.z).angle()
	# print_.fancy_cam("[~~lock: yaw_cur=", rad_to_deg(current_yaw), " yaw_des=", rad_to_deg(desired_yaw), " delta_wrapped=", rad_to_deg(wrapf(desired_yaw - current_yaw, -PI, PI)), " len_h_start=", blend_start_horizontal_len)

	if is_blending:
		# --- SMOOTH BLEND (YAW INTERPOLATION) ---
		blend_timer += delta
		var t_linear = clamp(blend_timer / blend_duration, 0.0, 1.0)
		var t_eased := u.ease_in_out(t_linear)

		# get the target angle
		var desired_yaw_rad := desired_dir_xz.angle()
		
		# Interpolate from the fixed starting yaw to the current desired yaw.
		# lerp_angle correctly handles the shortest path (e.g., -170° to 170°).
		var blended_yaw_rad := lerp_angle(blend_start_yaw_rad, desired_yaw_rad, t_eased)
		
		# Reconstruct the offset vector from the blended angle and fixed radius
		var final_xz := Vector2.from_angle(blended_yaw_rad) * blend_start_horizontal_len
		lock_offset.x = final_xz.x
		lock_offset.z = final_xz.y

		if t_linear >= 1.0:
			is_blending = false
			# print_.fancy_cam("~~ LOCK BLEND FINISHED")
	else:
		# --- RESPONSIVE LOCK (DIRECT ASSIGNMENT) ---
		# After blending, snap directly to the desired orientation for control
		var current_horizontal_len = Vector2(lock_offset.x, lock_offset.z).length()
		
		# against a zero length if camera is perfectly vertical
		if current_horizontal_len < 0.0001:
			current_horizontal_len = blend_start_horizontal_len

		var final_xz = desired_dir_xz * current_horizontal_len
		lock_offset.x = final_xz.x
		lock_offset.z = final_xz.y

	# DEV
	# var nest_mount_vec_len := (fc.nest.global_position - fc.mount.global_position).length()
	# var delta_off_angle: float = pp.pp_v3_angle_deg(_off_before, lock_offset, false)
	# var arc_len = snapped(deg_to_rad(delta_off_angle) * nest_mount_vec_len, 0.00001)
	# print_.fancy_cam("[~~LOCK UPD rot ", u.fr(), "]",
	# 	" angle_delta_deg=", str(delta_off_angle),
	# 	" arc_len=", str(arc_len),
	# 	" off_b4=", pp.pp_vec3(_off_before), " |len=", pp.round_01(lock_offset.length()),
	# 	" off_after=", pp.pp_vec3(lock_offset), " |len=", pp.round_01(lock_offset.length()))


func input_mouse_movement(d_x: float, d_y: float) -> void:
	lock_offset = vertical_mouse_movement(d_x, d_y, lock_offset)
