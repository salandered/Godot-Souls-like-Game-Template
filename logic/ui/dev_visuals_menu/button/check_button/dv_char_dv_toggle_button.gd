class_name DVCharDVToggleButton
extends BaseDVSettingCheckButton


@export var key_char_t: DVS.CharacterType = DVS.CharacterType.UNKNOWN
@export var key_char_dvt: DVS.CharDVType = DVS.CharDVType.UNKNOWN


func get_dvc_key() -> int:
	var composite_key := BitKeyUtils.combine(key_char_t, key_char_dvt)
	return composite_key.value if not composite_key.err else -1
