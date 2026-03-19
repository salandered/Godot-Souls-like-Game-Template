@tool
class_name CameraMetricsGridManager
extends BaseMetricsGridManager

var _camera: FancyCamera


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_camera
	]


func get_dtc_op_key() -> DTS.KeyBOverlayPanel:
	return DTS.KeyBOverlayPanel.CAM_NODES


func initialize_implementation() -> void:
	super.initialize_implementation()
	
	var _cams := get_tree().get_nodes_in_group(Groups.Dev.FANCY_CAM)
	if not _cams.is_empty() and _cams[0] is FancyCamera:
		_camera = _cams[0]


func nth_frame() -> int:
	return 4


func _process_implementation(delta: float) -> void:
	if not _camera: return
	
	_update_camera_metrics()


func _update_camera_metrics() -> void:
	if not _camera \
		or not _camera.player \
		or not _camera.socket \
		or not _camera.current_state \
		or not _camera.camera:
		return

	var p_pos := _camera.player.global_position
	var pivot_pos := _camera.pivot.global_position
	var socket_pos := _camera.socket.global_position
	var cam_pos := _camera.camera.global_position
	
	# state
	_metrics_grid.update_metric("State", _camera.current_state.state_name, true, +2)
	
	# target
	var target_name := "-"
	if _camera.locked_target:
		target_name = _camera.locked_target.pp_name()
	_metrics_grid.update_metric("Target", target_name)

	# boom compression
	var boom_ideal := pivot_pos.distance_to(socket_pos)
	var boom_real := pivot_pos.distance_to(cam_pos)
	
	var compression_ratio := 0.0
	if boom_ideal > 0.001:
		compression_ratio = boom_real / boom_ideal
	
	_metrics_grid.update_metric("Boom Ideal/Real", Vector2(boom_ideal, boom_real), false)
	_metrics_grid.update_metric("Compression %", compression_ratio)

	# misc
	_metrics_grid.update_metric("FOV", _camera.camera.fov)
	_metrics_grid.update_metric("Collision Enabled", _camera.__dev_camera_coll)


	# Tactical Angle
	if _camera.locked_target and _camera.player.camera_focus:
		var t_pos := _camera.locked_target.global_position
		var focus_pos := _camera.player.camera_focus.global_position
		
		var player_to_target := Vector2(t_pos.x - focus_pos.x, t_pos.z - focus_pos.z).normalized()
		var cam_to_target := Vector2(t_pos.x - cam_pos.x, t_pos.z - cam_pos.z).normalized()
		
		var align_angle := rad_to_deg(player_to_target.angle_to(cam_to_target))
		_metrics_grid.update_metric("Align Angle", align_angle)

	# Distances
	var dist_sock := p_pos.distance_to(socket_pos)
	_metrics_grid.update_metric("Player->Socket", dist_sock, true, -2)
	
	var dist_cam := p_pos.distance_to(cam_pos)
	_metrics_grid.update_metric("Player->Cam", dist_cam, true, -2)

	# State specific booms
	var free_boom_len := 0.0
	if _camera.free_state and _camera.free_state.free_boom:
		free_boom_len = _camera.free_state.free_boom.length()
	_metrics_grid.update_metric("Boom length", free_boom_len, true, -2)

	var lock_boom_len := 0.0
	if _camera.locked_state and _camera.locked_state.lock_boom:
		lock_boom_len = _camera.locked_state.lock_boom.length()
	_metrics_grid.update_metric("Boom length (locked state)", lock_boom_len, true, -2)
