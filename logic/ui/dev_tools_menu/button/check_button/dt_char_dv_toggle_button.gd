class_name DTCharDVToggleButton
extends BaseDVSettingCheckButton


@export var key_char_t: DTS.CharacterType = DTS.CharacterType.UNKNOWN
@export var key_char_dvt: DTS.CharDVType = DTS.CharDVType.UNKNOWN


func get_dtc_key() -> int:
	var composite_key := BitKeyUtils.combine(key_char_t, key_char_dvt)
	return composite_key.value if not composite_key.err else -1
