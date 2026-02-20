class_name DVCSIGPayloadParser
extends RefCounted


## THOUGHTS 1
## - horrible amount of code, but if its 'low level' framework which is written once and used forever it's ok
## - it's not only about DV or DVC (dev visuals and dev visials config). If all go well, this pattern will be reused
##   for project configuration and saving system 
##		(currently run by maaacks game template which has issues and btw looks the same to the DVC workflow)
## THOUGHTS 2
##  - more specific domain aware helpers. probably should not be here
##  - should be part of the signal itself 
##  - (some structure which knows signal, its payload and functions to write/read payload according to schema)


## DVC | GET PARSED PAYLOAD
# region

## dv control buttons emit this sig
static func parse_dvc_ui_control_value_changed(
	payload: Dictionary[String, Variant],
	allow_null_value: bool = false
) -> DVCUIControlValueChangedPayload:
	var _r_skv := _parse_dvc_section_key_value(payload, allow_null_value)
	if not _r_skv: return null
	var _r_button_name := SigUtils.safe_get_string_payload_value(payload, SPS.button_name_field)
	if _r_button_name.err: return
	return DVCUIControlValueChangedPayload.new(_r_skv.section, _r_skv.key, _r_skv.value, _r_button_name.value)


## internal sig used for distribution
static func parse_internal_SIG_dvc_value_changed(
	payload: Dictionary[String, Variant],
	allow_null_value: bool = false
) -> DVValueChangedPayload:
	var _r_skv := _parse_dvc_section_key_value(payload, allow_null_value)
	if not _r_skv: return null

	return DVValueChangedPayload.new(_r_skv.section, _r_skv.key, _r_skv.value)


## "boolean char dev visuals value changed"
static func parse_dvc_b_char_dv_value_changed(
	payload: Dictionary[String, Variant],
) -> DVCBValueChangedCharDVPayload:
	var _r_kv := _parse_dvc_key_value_payload(
		payload,
	)
	if not _r_kv: return null
	if not _r_kv.value is bool: return null
	var _r_split := DVS.get_enums_from_key_char_dv(_r_kv.key)
	if _r_split == Vector2i(-1, -1):
		return null
	return DVCBValueChangedCharDVPayload.new(
		_r_kv.key,
		_r_kv.value as bool,
		_r_split.x,
		_r_split.y
	)


## enum_to_validate_key should be Dictionary
static func parse_b_dvc_value_changed(
	payload: Dictionary[String, Variant],
	enum_to_validate_key: Variant = null,
) -> DVCBValueChangedPayload:
	var _parsed := parse_untyped_dvc_value_changed(payload, enum_to_validate_key, false)
	if not _parsed or _parsed.value is not bool:
		return
	return DVCBValueChangedPayload.new(_parsed.key, _parsed.value as bool)


## enum_to_validate_key should be Dictionary
static func parse_untyped_dvc_value_changed(
	payload: Dictionary[String, Variant],
	enum_to_validate_key: Variant = null,
	allow_null_value: bool = false
) -> DVCUntypedValueChangedPayload:
	var _r_kv := _parse_dvc_key_value_payload(
		payload,
		allow_null_value,
		false,
		-1,
		## true while enum_to_validate_key actually can be not passed
		## still will be fine 
		true,
		enum_to_validate_key
	)
	if not _r_kv: return
	return DVCUntypedValueChangedPayload.new(_r_kv.key, _r_kv.value)

	
# endregion


## DVC | GET VALUE BY KEY
# region

static func safe_bget_value_by_dvc_key(
	payload: Dictionary[String, Variant],
	key: int,
) -> RO.BoolReturn:
	var _r := safe_get_variant_value_by_dvc_key(payload, key)
	if _r.err or _r.value is not bool: return RO.BoolReturn.new(true)
	return RO.BoolReturn.new(false, _r.value as bool)


static func safe_fget_value_by_dvc_key(
	payload: Dictionary[String, Variant],
	key: int,
) -> RO.FloatReturn:
	var _r := safe_get_variant_value_by_dvc_key(payload, key)
	if _r.err or (_r.value is not float and _r.value is not int): return RO.FloatReturn.new(true)
	return RO.FloatReturn.new(false, float(_r.value))


static func safe_sget_value_by_dvc_key(
	payload: Dictionary[String, Variant],
	key: int,
) -> RO.StringReturn:
	var _r := safe_get_variant_value_by_dvc_key(payload, key)
	if _r.err or (_r.value is not String): return RO.StringReturn.new(true)
	return RO.StringReturn.new(false, _r.value as String)


static func safe_color_get_value_by_dvc_key(
	payload: Dictionary[String, Variant],
	key: int,
) -> RO.ColorReturn:
	var _r := safe_get_variant_value_by_dvc_key(payload, key)
	if _r.err or (_r.value is not Color): return RO.ColorReturn.new(true)
	return RO.ColorReturn.new(false, _r.value as Color)


static func safe_get_variant_value_by_dvc_key(
	payload: Dictionary[String, Variant],
	key: int,
	allow_null_value: bool = false
) -> RO.VariantReturn:
	var _r_kv := _parse_dvc_key_value_payload(
		payload,
		allow_null_value,
		true,
		key,
	)
	if not _r_kv: return RO.VariantReturn.new(true)
	return RO.VariantReturn.new(false, _r_kv.value)

# endregion


## DVC | GET VALUE BY COMPOSITE KEY
# region

static func safe_bget_value_by_composite_dvc_key(
	payload: Dictionary[String, Variant],
	ct: DVS.CharacterType,
	cdv: DVS.CharDVType
) -> RO.BoolReturn:
	var _r := safe_get_variant_value_by_composite_dvc_key(
		payload,
		ct,
		cdv,
		)
	if _r.err or _r.value is not bool: return RO.BoolReturn.new(true)
	return RO.BoolReturn.new(false, _r.value as bool)


static func safe_get_variant_value_by_composite_dvc_key(
	payload: Dictionary[String, Variant],
	ct: DVS.CharacterType,
	cdv: DVS.CharDVType,
	allow_null_value: bool = false
) -> RO.VariantReturn:
	var _r_kv := _parse_dvc_key_value_payload(
		payload,
		allow_null_value,
		true,
		DVS.key_char_dv(ct, cdv),
	)
	if not _r_kv: return RO.VariantReturn.new(true)
	return RO.VariantReturn.new(false, _r_kv.value)

# endregion


## INTERNAL

static func _parse_dvc_section_key_value(
	payload: Dictionary[String, Variant],
	allow_null_value: bool = false
) -> _DVCSectionKeyValuePayload:
	var _r_section := SigUtils.safe_get_int_payload_value(payload, SPS.dvc_section_field)
	if _r_section.err: return
	if not EnumUtils.safe_has_value(DVS.DVSection, _r_section.value):
		return

	var _r_kv := _parse_dvc_key_value_payload(payload, allow_null_value)

	return _DVCSectionKeyValuePayload.new(_r_section.value, _r_kv.key, _r_kv.value)


static func _parse_dvc_key_value_payload(
	payload: Dictionary[String, Variant],
	allow_null_value: bool = false,
	filter_by_key: bool = false,
	filter_key: int = -1,
	filter_by_key_enum: bool = false,
	key_enum: Variant = null
) -> _DVCSectionKeyValuePayload:
	var _r_key := SigUtils.safe_get_int_payload_value(payload, SPS.dvc_key_field)
	if _r_key.err: return

	if filter_by_key and _r_key.value != filter_key:
		return
	if filter_by_key_enum \
		and key_enum \
		and key_enum is Dictionary \
		and not EnumUtils.safe_has_value(key_enum, _r_key.value):
		return

	var _r_value := SigUtils.safe_get_variant_payload_value(payload, SPS.dvc_value_field, allow_null_value)
	if _r_value.err: return

	return _DVCKeyValuePayload.new(_r_key.value, _r_value.value)


## PARSED PAYLOAD
# region

class DVCBValueChangedCharDVPayload extends DVCUntypedValueChangedPayload:
	var char_type: DVS.CharacterType
	var char_dv_type: DVS.CharDVType
	var value_as_bool: bool

	func _init(k: int, v: bool, ct: int, dvt: int):
		super._init(k, v)
		value_as_bool = v
		char_type = ct as DVS.CharacterType
		char_dv_type = dvt as DVS.CharDVType


class DVCBValueChangedPayload extends DVCUntypedValueChangedPayload:
	var value_as_bool: bool

	func _init(k: int, v: bool):
		super._init(k, v)
		value_as_bool = v


class DVCUntypedValueChangedPayload extends _DVCKeyValuePayload:
	pass


class DVCUIControlValueChangedPayload extends _DVCSectionKeyValuePayload:
	var button_name: String

	func _init(s: DVS.DVSection, k: int, v: Variant, bn: String):
		super._init(s, k, v)
		button_name = bn


class DVValueChangedPayload extends _DVCSectionKeyValuePayload:
	pass


class _DVCSectionKeyValuePayload extends _DVCKeyValuePayload:
	var section: DVS.DVSection

	func _init(s: DVS.DVSection, k: int, v: Variant):
		super._init(k, v)
		section = s


class _DVCKeyValuePayload:
	var key: int
	var value: Variant

	func _init(k: int, v: Variant):
		key = k
		value = v

# endregion
