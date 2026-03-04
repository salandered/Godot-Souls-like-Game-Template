class_name DTOverlayPanelToggleButton
extends BaseDVSettingCheckButton


@export var key_panel: DTS.KeyBOverlayPanel = DTS.KeyBOverlayPanel.UNKNOWN


func get_dtc_key() -> int:
	return key_panel
