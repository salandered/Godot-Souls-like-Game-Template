class_name DVValueChangerToggleButton
extends BaseDVSettingCheckButton


@export var key_value_changer: DVS.KeyValueChanger = DVS.KeyValueChanger.UNKNOWN


func get_dvc_key() -> int:
	return key_value_changer
