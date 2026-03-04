class_name DTValueChangerToggleButton
extends BaseDVSettingCheckButton


@export var key_value_changer: DTS.KeyBValueChanger = DTS.KeyBValueChanger.UNKNOWN


func get_dtc_key() -> int:
	return key_value_changer
