class_name SigUtils
extends RefCounted


## returns true if emitted
static func safe_emit(
	signal_data: SignalData,
	signal_payload: Dictionary[String, Variant],
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	if error_.null_object(signal_data, "no signal data", warn_level):
		return false
	if error_.null_signal(signal_data.signal_obj, "", warn_level):
		return false
	signal_data.signal_obj.emit(signal_payload)
	if __log:
		print_.prefix("<emit>", pp.sig(signal_data, signal_payload))
	return true


static func safe_emit_raw(
	signal_: Signal,
	signal_payload: Dictionary[String, Variant],
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	if error_.null_signal(signal_, "", warn_level):
		return false
	signal_.emit(signal_payload)
	if __log:
		print_.prefix("<emit>", pp.sig_raw(signal_, signal_payload))
	return true

static func safe_emit_raw_toggle(
	signal_: Signal,
	toggle: bool,
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	return safe_emit_raw(signal_, {SPS.toggle_field: toggle})


static func safe_emit_raw_no_payload(
	signal_: Signal,
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	if error_.null_signal(signal_, "", warn_level):
		return false
	signal_.emit()
	if __log:
		print_.prefix("<emit>", pp.sig_raw(signal_, {}))
	return true


static func safe_connect(
	signal_: Signal,
	callable: Callable,
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	if error_.null_signal(signal_, "", warn_level):
		return false
	if not callable.is_valid():
		error_.warn("callable is not valid", "", "", warn_level)
		return false
	if signal_.is_connected(callable):
		return false

	signal_.connect(callable)
	
	if __log:
		print_.prefix("<connected>", pp.sig_raw(signal_, {}))
	return true


static func safe_disconnect(
	signal_: Signal,
	callable: Callable,
	__log: bool = false,
	warn_level: String = WL.WARN) -> bool:
	if error_.null_signal(signal_, "", warn_level):
		return false
	if not callable.is_valid():
		error_.warn("callable is not valid", "", "", warn_level)
		return false
	if not signal_.is_connected(callable):
		return false

	signal_.disconnect(callable)
	
	if __log:
		print_.prefix("<disconnected>", pp.sig_raw(signal_, {}))
	return true


static func safe_connect_pairs(
	pairs: Array[Array],
	__log: bool = false,
	warn_level: String = WL.WARN):
	for pair: Array in pairs:
		if not _validate_signal_pair(pair, warn_level):
			continue
		safe_connect(pair[0], pair[1], __log, warn_level)
	

static func safe_disconnect_pairs(
	pairs: Array[Array],
	__log: bool = false,
	warn_level: String = WL.WARN):
	for pair in pairs:
		if not _validate_signal_pair(pair, warn_level):
			continue
		safe_disconnect(pair[0], pair[1], __log, warn_level)


static func _validate_signal_pair(pair: Array, warn_level: String) -> bool:
	if len(pair) != 2:
		error_.warn("signal pair should consist of two elements", "", "", warn_level)
		return false
	if pair[0] is not Signal:
		error_.warn("first pair element is not signal", "", "", warn_level)
		return false
	if pair[1] is not Callable:
		error_.warn("second pair element is not callable", "", "", warn_level)
		return false
	return true
		

static func build_payload(key: String, value: Variant) -> Dictionary[String, Variant]:
	var d: Dictionary[String, Variant] = {key: value}
	return d


static func safe_get_int_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.WARN
) -> ReturnObject.IntReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return ReturnObject.IntReturn.new(true)
		
	var payload_value = payload_value_return.value

	if not (payload_value is int):
		error_.warn("not not (payload_value is int)", "", "", warn_level, payload, payload_key)
		return ReturnObject.IntReturn.new(true)

	return ReturnObject.IntReturn.new(false, payload_value)


## returns value as a float
static func safe_get_int_float_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.WARN
) -> ReturnObject.FloatReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return ReturnObject.FloatReturn.new(true)
		
	var payload_value = payload_value_return.value

	if not (payload_value is float or payload_value is int):
		error_.warn("not not (payload_value is float or payload_value is int)", "", "", warn_level, payload, payload_key)
		return ReturnObject.FloatReturn.new(true)

	return ReturnObject.FloatReturn.new(false, float(payload_value))


static func safe_get_bool_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.WARN
) -> ReturnObject.BoolReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return ReturnObject.BoolReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is bool):
		error_.warn("not (payload_value is bool)", "", "", warn_level, payload, payload_key)
		return ReturnObject.BoolReturn.new(true)

	return ReturnObject.BoolReturn.new(false, payload_value)

static func safe_get_toggle_payload_value(
		payload: Dictionary[String, Variant],
		warn_level: String = WL.WARN
) -> ReturnObject.BoolReturn:
	var r := safe_get_bool_payload_value(payload, SPS.toggle_field)
	return r


static func safe_get_string_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.WARN
) -> ReturnObject.StringReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return ReturnObject.StringReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is String):
		error_.warn("not (payload_value is String)", "", "", warn_level, payload, payload_key)
		return ReturnObject.StringReturn.new(true)

	return ReturnObject.StringReturn.new(false, payload_value)


static func safe_get_dict_payload_value(payload: Dictionary[String, Variant],
	payload_key: String,
	null_allowed: bool,
	warn_level: String = WL.WARN
) -> ReturnObject.DictReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return ReturnObject.DictReturn.new(true, {})
	var payload_value = payload_value_return.value
	if not (payload_value is Dictionary):
		error_.warn("not (payload_value is Dictionary)", "", "", warn_level, payload, payload_key)
		return ReturnObject.DictReturn.new(true, {})

	return ReturnObject.DictReturn.new(false, payload_value)


static func safe_get_variant_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		null_allowed: bool,
		warn_level: String = WL.WARN
) -> ReturnObject.VariantReturn:
	return _get_value_by_key(payload, payload_key, null_allowed, warn_level)


static func _get_value_by_key(
		payload: Dictionary[String, Variant],
		payload_key: String,
		null_allowed: bool = true,
		warn_level: String = WL.WARN
) -> ReturnObject.VariantReturn:
	if not DictUtils.safe_has_key(payload, payload_key, warn_level):
		return ReturnObject.VariantReturn.new(true)

	var payload_value = payload[payload_key]

	if not null_allowed and payload_value == null:
		error_.warn("not null_allowed and payload_value == null", "", "", warn_level, payload, payload_key)
		return ReturnObject.VariantReturn.new(true)

	return ReturnObject.VariantReturn.new(false, payload_value)


## more specific domain aware helpers. probably should not be here

## should be part of the signal itself 
## (some structure which knows signal, its payload and functions to write/read payload according to schema)
## returns either succesfull MatrixCdvToggledPayload or null
static func safe_get_SIG_matrix_cdv_toggled_payload(
	payload: Dictionary[String, Variant]
) -> MatrixCdvToggledPayload:
	var _r_toggle := safe_get_toggle_payload_value(payload)
	if _r_toggle.err:
		return

	var _r_char_type := safe_get_int_payload_value(payload, SPS.char_type_field)
	if _r_char_type.err:
		return
	var _r_dv_type := safe_get_int_payload_value(payload, SPS.dv_type_field)
	if _r_dv_type.err:
		return
	
	if not EnumUtils.safe_has_value(DevVisualsConfig.CharacterType, _r_char_type.value):
		return
	if not EnumUtils.safe_has_value(DevVisualsConfig.DevVisualsType, _r_dv_type.value):
		return
	return MatrixCdvToggledPayload.new(_r_toggle.value, _r_char_type.value, _r_dv_type.value)

	
class MatrixCdvToggledPayload:
	var toggle: bool
	var char_type: DevVisualsConfig.CharacterType
	var dv_type: DevVisualsConfig.DevVisualsType

	func _init(t: bool, ct: DevVisualsConfig.CharacterType, dt: DevVisualsConfig.DevVisualsType):
		toggle = t
		char_type = ct
		dv_type = dt