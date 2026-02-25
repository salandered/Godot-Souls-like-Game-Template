@tool
extends BaseDVCDependentNode


@export var camera: FancyCamera


func initialise() -> void:
	SigUtils.safe_connect_pairs(
	[
		[GlobalSignal.SIG_toggle_camera_coll, _on_SIG_toggle_camera_coll],
		[GlobalUIInfo.SIG_dvc_b_overlay_panel_value_changed, _on_SIG_dvc_value_changed_section_op],
	]
)


func reset_visuals() -> void:
	pass


func _on_SIG_toggle_camera_coll(payload: Dictionary[StringName, Variant]):
	if not camera: return
	if not camera.is_node_ready(): return
	
	var _r := SigUtils.safe_get_bool_payload_value(payload, SPS.toggle_field)
	if _r.err: return
	camera._toggle_cam_coll(_r.value)


func _on_SIG_dvc_value_changed_section_op(payload: Dictionary[StringName, Variant]):
	if not camera: return
	if not camera.is_node_ready(): return
	
	var parsed_payload := DVCSIGPayloadParser.parse_b_dvc_value_changed(payload)
	if not parsed_payload:
		return
	var dvc_key := parsed_payload.key
	var toggle := parsed_payload.value_as_bool
	match dvc_key:
		DVS.KeyBOverlayPanel.SUBVIEWPORT:
			camera.set_h_offset_camera(+0.7 if toggle else 0.0)
		DVS.KeyBOverlayPanel.PLAYER_SK_ANIMATOR:
			camera.add_v_offset_camera(-camera.v_offset_step * 4 if toggle else camera.v_offset_step * 4)
