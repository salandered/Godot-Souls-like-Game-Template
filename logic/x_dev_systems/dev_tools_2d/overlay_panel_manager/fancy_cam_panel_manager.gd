@tool
class_name DebugFancyCamManager
extends BasePanelManager


@onready var controls_info_panel: PanelContainer = %ControlsInfoPanel


func get_ui_panel() -> Container:
	return controls_info_panel


func _supported_signal_pairs() -> Array[Array]:
	return []


func get_dtc_op_key() -> DTS.KeyBOverlayPanel:
	return DTS.KeyBOverlayPanel.CAM_NODES
