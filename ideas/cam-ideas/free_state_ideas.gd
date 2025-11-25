extends CameraState
# class_name FreeCameraState


var look_at_: Node3D # CameraFocus node while not locked
var offset: Vector3

var _current_len: float
var _default_len: float
var _unlock_freeze_frames := 0
 
	# COL MOVE CAMERA
 	# var min_hit_len := CameraCollisions._calc_min_hit_len_via_raycasts(arm_dir, from, to, desired_len, fc)

	# # Apply collision free_offset along the arm direction
	# if min_hit_len < desired_len:
	# 	target_len = min(min_hit_len - fc.COL_OFFSET, _default_len)

	# # --- asymmetric smoothing (contract now, expand smoothly)
	# if target_len < _current_len:
	# 	_current_len = target_len # instant contract (A/C)
	# else:
	# 	var k := 1.0 - exp(-delta / fc.COL_EXPAND_TIME) # smooth grow (B)
	# 	var step := (target_len - _current_len) * k
	# 	var cap := fc.COL_MAX_EXPAND_SPEED * delta
	# 	if step > cap:
	# 		step = cap
	# 	_current_len += step

	# # --- place camera using the smoothed length
	# final_pos = from + arm_dir * _current_len
	
	# # Final check to ensure we're not clipping through geometry
	# if CameraCollisions._check_camera_penetration(final_pos, fc):
	# 	final_pos = CameraCollisions._resolve_penetration(from, final_pos, arm_dir, fc)
	
	# fc.camera.global_position = final_pos
	# u.safe_look_at(fc.camera, fc.focus.global_position)


func update(delta: float):
	# Character moved: 
	# - First Focus Point follows the character. 
	# - Then Camera Mount and Camera Nest mimics Focus movements, 
	#   but we don't want to change the offset length, and we don't want to simply translate it.
	# - In the end, adjust camera position and the line of sight.
	var prev_focus_pos = fc.focus.global_position
	_move_focus_point()

	if _unlock_freeze_frames == 0:
		_rotate_offset(prev_focus_pos, fc.focus.global_position)

	_move_camera_mount_and_nest(delta)
	# _move_camera(delta)


func _move_focus_point() -> void:
	# look_at_ is CameraFocus (chest) while in free state
	if not fc.focus.global_position.is_equal_approx(look_at_.global_position):
		# Focus Point follows player's chest
		fc.focus.global_position = lerp_position_(fc.focus, look_at_, fc.FREE_FOCUS_CHEST_WEIGHT)

# old version
func _rotate_offset(prev_focus_pos: Vector3, new_focus_pos: Vector3) -> void:
	var new_focus_projected := Vector3(new_focus_pos.x, 0, new_focus_pos.z)
	var old_offset_projected := Vector3(-offset.x, 0, -offset.z)
	# if prev_focus_pos is changed to new, then no circular movement
	var center := prev_focus_pos + offset
	var center_projected := Vector3(center.x, 0, center.z)

	var new_direction := new_focus_projected - center_projected
	var alpha := new_direction.angle_to(old_offset_projected)

	var decider = new_direction.cross(old_offset_projected)
	var signed_alpha: float = alpha if decider.y < 0 else -alpha
	offset = offset.rotated(Vector3.UP, signed_alpha)


func _move_camera_mount_and_nest(delta: float) -> void:
	if _unlock_freeze_frames > 0:
		# not moving mount
		# optionally skip length solver on this frame to be 1:1 with live pose
		var desired_ := fc.mount.global_position + offset.normalized() * _current_len
		fc.nest.global_position = desired_
		_unlock_freeze_frames -= 1
		return

	# Normal path after the first frame
	fc.mount.global_position = lerp_position_(fc.mount, fc.player.camera_focus, fc.FREE_MOUNT_CHEST_WEIGHT)
	# _update_current_length(delta)
	var desired := fc.mount.global_position + offset.normalized() * _current_len
	fc.nest.global_position = lerp_position_(fc.nest, desired, fc.FREE_NEST_MOUNT_WEIGHT)
	
	# Used to be: fc.nest.global_position = fc.mount.global_position + offset

func _update_current_length(delta: float) -> void:
	# TypeCast from mount toward the ideal (default) length and compute allowed length.
	_current_len = lerp(_current_len, _default_len, 0.5)

# region: old docs
	# takes the Delta mouse movement and somehow counts a Delta angle from that movement length.
	# Then, we rotate offset vector by that angle using the correspondent axis.
	# Delta movements are very small, and `sin(Alpha) ~ Alpha`. 
	#    => divide by a thousand and multiply by a sensitivity number for the user to modify the sensitivity.
	# For the horizontal movement, it's always ok because the rotation axis is just a vertical axis.
	# The axis of vertical rotation is dynamic; we need to calculate it.
	#    - Use vector operation called Vector Cross Product (or Vector Crossing). 
	#			(Built-in way to get a vector which is perpendicular to two given vectors simultaneously.)
	#    - One of such vectors is the vertical axis, and the other one is just our offset.
func input_mouse_movement(d_x: float, d_y: float) -> void:
	offset = offset.rotated(Vector3.UP, -d_x * fc.HOR_SENSE * 0.001)

	var axis := offset.cross(Vector3.UP).normalized()
	var angle = d_y * fc.VER_SENSE * 0.001
	var new_offset = offset.rotated(axis, angle)
	var new_offset_angle = new_offset.angle_to(Vector3.UP)
	if new_offset_angle > fc.MIN_VERTICAL_ANGLE and new_offset_angle < fc.MAX_VERTICAL_ANGLE:
		offset = new_offset
	
func check_relevance():
	var found_target = fc.player.model.area_awareness.find_target()
	if found_target:
		fc.locked_target = found_target
		print_.fancy_cam("", "		fc.found_target " + str(fc.locked_target))
		fc.current_state = fc.locked_camera
		fc.locked_camera.look_at_ = fc.locked_target.look_at_point
		
		var arm_vector = fc.camera.global_position - fc.mount.global_position

		fc.locked_camera.offset_basis = arm_vector
		fc.locked_camera.offset = arm_vector
		fc.locked_camera.offset_transition_t = 0.0
		fc.locked_camera._blending = true
		fc.locked_camera._just_locked = true

		print_.fancy_cam("", "LOCK SUCCESFULL")
	else:
		print_.fancy_cam("", "xLOCK NOT")


# func _move_camera(delta: float) -> void:
# 	var from := fc.mount.global_position
# 	var to := fc.nest.global_position
# 	var arm_dir := (to - from).normalized()
# 	var desired_len := (to - from).length()
# 	var target_len: float = min(desired_len, _default_len)
# 	var final_pos: Vector3

# 	if not fc.__dev_camera_cols:
# 		final_pos = from + arm_dir * _current_len
# 		fc.camera.global_position = final_pos
# 		u.safe_look_at(fc.camera, fc.focus.global_position)
# 		return

# 	var min_hit_len := _calc_min_hit_len_via_raycasts(arm_dir, from, to, desired_len)

# 	# Apply collision offset along the arm direction
# 	if min_hit_len < desired_len:
# 		target_len = min(min_hit_len - fc.COL_OFFSET, _default_len)

# 	# --- asymmetric smoothing (contract now, expand smoothly)
# 	if target_len < _current_len:
# 		_current_len = target_len # instant contract (A/C)
# 	else:
# 		var k := 1.0 - exp(-delta / fc.COL_EXPAND_TIME) # smooth grow (B)
# 		var step := (target_len - _current_len) * k
# 		var cap := fc.COL_MAX_EXPAND_SPEED * delta
# 		if step > cap:
# 			step = cap
# 		_current_len += step

# 	# --- place camera using the smoothed length
# 	final_pos = from + arm_dir * _current_len
	
# 	# Final check to ensure we're not clipping through geometry
# 	if _check_camera_penetration(final_pos):
# 		final_pos = _resolve_penetration(from, final_pos, arm_dir)
	
# 	fc.camera.global_position = final_pos
# 	u.safe_look_at(fc.camera, fc.focus.global_position)


# LOGGING MOUSE ROTATION

const VERT_EPS := 0.003 # ~0.17° tolerance
const DEG := 57.295779513 # rad→deg


# var __dbg_last_geom_pitch := NAN
# var __dbg_last_off_pitch := NAN

# func __pitch_from_offset_rad(v: Vector3) -> float:
# 	var xz_len := Vector2(v.x, v.z).length()
# 	return atan2(v.y, xz_len) # pitch vs horizontal plane

# func __theta_from_up_rad(v: Vector3) -> float:
# 	# angle to UP (0=straight up, PI/2=horizontal). This matches your MIN/MAX checks.
# 	var n := v.normalized()
# 	var dot = clamp(n.dot(Vector3.UP), -1.0, 1.0)
# 	return acos(dot)

# func __geom_pitch_rad() -> float:
# 	# Geometry: from mount to camera (what actually got placed)
# 	var d := fc.camera.global_position - fc.mount.global_position
# 	var xz := Vector2(d.x, d.z).length()
# 	return atan2(d.y, xz)

# func __log_vert_pre_mouse(d_x: float, d_y: float) -> void:
# 	# Predict what your current input will try to do (before your if-check).
# 	var off_pitch := __pitch_from_offset_rad(free_offset)
# 	var theta_up := __theta_from_up_rad(free_offset)

# 	var vertical_axis := free_offset.cross(Vector3.UP).normalized()
# 	var rot_angle := d_y * fc.FREE_VER_SENSE * 0.001
# 	var predicted := free_offset.rotated(vertical_axis, rot_angle)
# 	var predicted_theta := __theta_from_up_rad(predicted)

# 	var allow := predicted_theta > fc.MIN_VERTICAL_ANGLE and predicted_theta < fc.MAX_VERTICAL_ANGLE

# 	print_.fancy_cam("[~~FREE VERT pre ", u.fr(), "]",
# 		" off_pitch=", str(off_pitch * DEG),
# 		" theta_up=", str(theta_up * DEG),
# 		" pred_theta=", str(predicted_theta * DEG),
# 		" MIN=", str(fc.MIN_VERTICAL_ANGLE * DEG),
# 		" MAX=", str(fc.MAX_VERTICAL_ANGLE * DEG),
# 		" allow?=", str(allow),
# 		" dx=", str(d_x), " dy=", str(d_y))

# func __log_vert_post_frame() -> void:
# 	var off_pitch := __pitch_from_offset_rad(free_offset)
# 	var geom_pitch := __geom_pitch_rad()

# 	var theta_off := __theta_from_up_rad(free_offset)
# 	var cam_vec := fc.camera.global_position - fc.mount.global_position
# 	var theta_geom := __theta_from_up_rad(cam_vec)

# 	var breach_min := theta_off < (fc.MIN_VERTICAL_ANGLE - VERT_EPS)
# 	var breach_max := theta_off > (fc.MAX_VERTICAL_ANGLE + VERT_EPS)

# 	var d_off := NAN
# 	var d_geom := NAN
# 	if __dbg_last_off_pitch == __dbg_last_off_pitch:
# 		d_off = (off_pitch - __dbg_last_off_pitch) * DEG
# 	if __dbg_last_geom_pitch == __dbg_last_geom_pitch:
# 		d_geom = (geom_pitch - __dbg_last_geom_pitch) * DEG

# 	print_.fancy_cam("[~~FREE VERT post ", u.fr(), "]",
# 		" off_pitch=", str(off_pitch * DEG),
# 		" geom_pitch=", str(geom_pitch * DEG),
# 		" θ_off=", str(theta_off * DEG),
# 		" θ_geom=", str(theta_geom * DEG),
# 		" Δoff_deg=", str(d_off),
# 		" Δgeom_deg=", str(d_geom),
# 		" BREACH_MIN=", str(breach_min),
# 		" BREACH_MAX=", str(breach_max))

# 	__dbg_last_off_pitch = off_pitch
# 	__dbg_last_geom_pitch = geom_pitch
