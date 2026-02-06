class_name DebugFancyCamManager
extends BasePanelManager


@onready var debug_fancy_cam_panel: MarginContainer = %DebugFancyCamPanel


func get_ui_panel() -> Container:
	return debug_fancy_cam_panel


func _supported_signal_pairs() -> Array[Array]:
	return [] as Array[Array]


func _get_enabler_sig() -> Variant:
	return GlobalUIInfo.SIG_dvc_value_changed_section_op


func _parse_enabler_sig(payload: Dictionary[String, Variant]) -> RO.BoolReturn:
	var _r := SigPayloadParser.safe_bget_value_by_key_from_SIG_dvc_value_changed_section_payload(
		payload,
		DVS.KeyOverlayPanel.CAM_NODES
		)
	return _r
