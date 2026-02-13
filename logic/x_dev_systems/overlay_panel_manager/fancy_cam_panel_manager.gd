@tool
class_name DebugFancyCamManager
extends BasePanelManager


@onready var controls_info_panel: PanelContainer = %ControlsInfoPanel


func get_ui_panel() -> Container:
	return controls_info_panel


func _supported_signal_pairs() -> Array[Array]:
	return []


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.CAM_NODES
