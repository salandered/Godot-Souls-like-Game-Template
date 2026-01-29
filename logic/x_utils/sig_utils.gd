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
	return safe_emit_raw(signal_, {GlobalSignal.payload_toggle_field: toggle})


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


## returns value as a float
static func safe_get_int_float_payload_value(payload: Dictionary[String, Variant], payload_key: String) -> ReturnObject.FloatReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false)
	if payload_value_return.err:
		return ReturnObject.FloatReturn.new(true)
		
	var payload_value = payload_value_return.value

	if not (payload_value is float or payload_value is int):
		return ReturnObject.FloatReturn.new(true)

	return ReturnObject.FloatReturn.new(false, float(payload_value))


static func safe_get_bool_payload_value(payload: Dictionary[String, Variant], payload_key: String) -> ReturnObject.BoolReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false)
	if payload_value_return.err:
		return ReturnObject.BoolReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is bool):
		return ReturnObject.BoolReturn.new(true)

	return ReturnObject.BoolReturn.new(false, payload_value)

static func safe_get_toggle_payload_value(payload: Dictionary[String, Variant]) -> ReturnObject.BoolReturn:
	var r := safe_get_bool_payload_value(payload, GlobalSignal.payload_toggle_field)
	return r


static func safe_get_string_payload_value(payload: Dictionary[String, Variant], payload_key: String) -> ReturnObject.StringReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false)
	if payload_value_return.err:
		return ReturnObject.StringReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is String):
		return ReturnObject.StringReturn.new(true)

	return ReturnObject.StringReturn.new(false, payload_value)


static func safe_get_dict_payload_value(payload: Dictionary[String, Variant], payload_key: String, null_allowed: bool) -> ReturnObject.DictReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false)
	if payload_value_return.err:
		return ReturnObject.DictReturn.new(true, {})
	var payload_value = payload_value_return.value
	if not (payload_value is Dictionary):
		return ReturnObject.DictReturn.new(true, {})

	return ReturnObject.DictReturn.new(false, payload_value)

static func safe_get_variant_payload_value(payload: Dictionary[String, Variant], payload_key: String, null_allowed: bool) -> ReturnObject.VariantReturn:
	return _get_value_by_key(payload, payload_key, null_allowed)


static func _get_value_by_key(payload: Dictionary[String, Variant], payload_key: String, null_allowed: bool = true) -> ReturnObject.VariantReturn:
	if not DictUtils.safe_has_key(payload, payload_key, WL.SILENT):
		return ReturnObject.VariantReturn.new(true)

	var payload_value = payload[payload_key]

	if not null_allowed and payload_value == null:
		return ReturnObject.VariantReturn.new(true)

	return ReturnObject.VariantReturn.new(false, payload_value)