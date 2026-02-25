@tool
extends BaseInputDevHotkeys


@export var camera: FancyCamera


var __fov_pointer := 0


func _unhandled_input_implementation(event: InputEvent) -> void:
	if not camera: return
	if not camera.is_node_ready(): return
	

	if event.is_action_pressed(RawAction.DEV_CAM_cols):
		_toggle_cam_coll(not camera.__dev_camera_coll)

	_handle_v_offset_scroll(event)
	_handle_fov_scroll(event)


func _handle_v_offset_scroll(event: InputEvent) -> void:
	if InputUtils.is_keycode_w_ctrl(event, KEY_KP_9):
		camera.add_v_offset_camera(camera.v_offset_step)
	elif InputUtils.is_keycode_w_ctrl(event, KEY_KP_6):
		camera.add_v_offset_camera(-camera.v_offset_step)


func _handle_fov_scroll(event: InputEvent) -> void:
	if InputUtils.is_keycode_w_ctrl(event, KEY_KP_7):
		camera.add_fov(-camera.fov_step)
	elif InputUtils.is_keycode_w_ctrl(event, KEY_KP_8):
		camera.add_fov(camera.fov_step)
				
				
func _toggle_cam_coll(toggle: bool):
	print_.dev("", "_toggle_cam_coll", toggle)
	camera.__dev_camera_coll = toggle


func _input_implementation(event: InputEvent) -> void:
	pass
