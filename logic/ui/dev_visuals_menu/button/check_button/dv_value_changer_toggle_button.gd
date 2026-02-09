class_name DVValueChangerToggleButton
extends BaseDVSettingCheckButton


@export var key_value_changer: DVS.KeyBValueChanger = DVS.KeyBValueChanger.UNKNOWN


func get_dvc_key() -> int:
	return key_value_changer
