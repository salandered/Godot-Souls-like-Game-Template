extends CameraState
class_name LockedCameraState

var target: Node3D
var lock_boom: Vector3

var blend_timer := SimpleTimer.new()
var BLEND_DURATION := 0.4 # 0.3-0.6 seconds (shorter = snappier lock, longer = smoother)

# State captured on the frame of locking, to anchor the blend
var blend_start_yaw_rad := 0.0
var blend_start_hor_len := 0.0


func switch_from_free(found_target: Node):
	target = found_target.look_at_point

	# capturing the true boom at the moment of locking to prevent any jump
	lock_boom = fc.socket.global_position - fc.pivot.global_position
	# tried: lock_boom = fc.camera.global_position - fc.pivot.global_position
	
	var cam_minus_pivot := fc.camera.global_position - fc.pivot.global_position
	var err := (cam_minus_pivot - lock_boom).length()
	# __log_("[~~ lock: err_to_boom_on_entry=", err)
	
	# store the initial conditions. The blend will always be from this
	# fixed start-point to the moving end-point.
	var current_boom_xz := Vector2(lock_boom.x, lock_boom.z)
	blend_start_yaw_rad = current_boom_xz.angle()

	blend_start_hor_len = current_boom_xz.length()
	if blend_start_hor_len < 0.05: # optional to try
		blend_start_hor_len = 0.05

	blend_timer.initialise(BLEND_DURATION)
	
	# __log_("switch post", fc.__dbg_main_info(), "target=", target)


func update(delta: float) -> void:
	# __log_("UPD", fc.__dbg_main_info())
	# move the anchor points
	_move_aim()
	_move_camera_pivot()
	
	# calculate the rotation based on their new positions
	_rotate_boom_locked(delta)
	
	# position the camera elements
	_move_camera_socket()
	fc.camera_movement.move_camera(delta)

	# TODO TODO: return check_distance
	# TODO: not only distance, but line of sight? 
	# 		what if enemy falls, we are doomed to look at floor

	# __log_("UPD post", fc.__Cvec(), fc.__CM(), fc.__CF())


func _move_aim() -> void:
	fc.aim.global_position = lerp_position_(fc.aim, target, fc.LOCKED_AIM_TARGET_WEIGHT)

func _move_camera_pivot() -> void:
	fc.pivot.global_position = lerp_position_(fc.pivot, fc.player.camera_focus, fc.LOCKED_PIVOT_CHEST_WEIGHT)

func _move_camera_socket() -> void:
	fc.socket.global_position = lerp_position_(fc.socket, fc.pivot.global_position + lock_boom, fc.LOCKED_SOCKET_PIVOT_WEIGHT)


func _rotate_boom_locked(delta: float) -> void:
	var _boom_before := lock_boom

	# desired direction is from the target to the camera's direct anchor (pivot).
	var desired_dir_xz := Vector2(fc.pivot.global_position.x - target.global_position.x, fc.pivot.global_position.z - target.global_position.z).normalized()

	# against zero radius (player is directly on top of the target or something)
	if desired_dir_xz.length_squared() < Constants.EPSILON_5: return

	var desired_yaw := desired_dir_xz.angle()
	var current_yaw := Vector2(_boom_before.x, _boom_before.z).angle()
	# __log_("yaw_cur", rad_to_deg(current_yaw), "yaw_des", rad_to_deg(desired_yaw), 
		# "delta_wrapped", rad_to_deg(wrapf(desired_yaw - current_yaw, -PI, PI)), "len_h_start", blend_start_hor_len)

	if not blend_timer.is_complete():
		# --- SMOOTH BLEND (YAW INTERPOLATION) ---
		blend_timer.update(delta)
		var t_linear := clampf(blend_timer.get_elapsed() / blend_timer.duration, 0.0, 1.0)
		var t_eased := u.ease_in_out(t_linear)

		# get the target angle
		var desired_yaw_rad := desired_dir_xz.angle()
		
		# Interpolate from the fixed starting yaw to the current desired yaw.
		# lerp_angle correctly handles the shortest path (e.g. -170 to 170).
		var blended_yaw_rad := lerp_angle(blend_start_yaw_rad, desired_yaw_rad, t_eased)
		
		# Reconstruct the boom vector from the blended angle and fixed radius
		var final_xz := Vector2.from_angle(blended_yaw_rad) * blend_start_hor_len
		lock_boom.x = final_xz.x
		lock_boom.z = final_xz.y
		# __log_("~~ LOCK BLEND FINISHED")
	else:
		# --- RESPONSIVE LOCK (DIRECT ASSIGNMENT) ---
		# After blending, snap directly to the desired orientation for control
		var current_hor_len := Vector2(lock_boom.x, lock_boom.z).length()
		
		# against a zero length if camera is perfectly vertical
		if current_hor_len < Constants.EPSILON_5:
			current_hor_len = blend_start_hor_len

		var final_xz := desired_dir_xz * current_hor_len
		lock_boom.x = final_xz.x
		lock_boom.z = final_xz.y

	# LOGS
	# var socket_pivot_vec_len := (fc.socket.global_position - fc.pivot.global_position).length()
	# var delta_off_angle: float = pp.pp_v3_angle_deg(_off_before, lock_boom, false)
	# var arc_len := snapped(deg_to_rad(delta_off_angle) * socket_pivot_vec_len, 0.00001)
	# __log_("[~~LOCK UPD rot ", u.sfr(), "]",
	# 	" angle_delta_deg=", str(delta_off_angle),
	# 	" arc_len=", str(arc_len),
	# 	" off_b4=", pp.pp_vec3(_off_before), " |len=", pp.round_01(lock_boom.length()),
	# 	" off_after=", pp.pp_vec3(lock_boom), " |len=", pp.round_01(lock_boom.length()))


func input_mouse_movement(d_x: float, d_y: float) -> void:
	lock_boom = vertical_mouse_movement(d_x, d_y, lock_boom)
