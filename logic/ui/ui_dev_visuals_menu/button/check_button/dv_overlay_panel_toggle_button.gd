class_name DVOverlayPanelToggleButton
extends BaseDVSettingCheckButton


@export var key_panel: DVS.KeyOverlayPanel = DVS.KeyOverlayPanel.UNKNOWN


func get_dvc_key() -> int:
	return key_panel
