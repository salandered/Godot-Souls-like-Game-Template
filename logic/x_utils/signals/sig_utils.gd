class_name SigUtils
extends RefCounted


static func __emit(signal_: Signal, with_payload: bool, payload: Dictionary):
	if with_payload:
		signal_.emit(payload)
	else:
		signal_.emit()


	if u.is_editor():
		return
	if GlobalUIInfo.__SIG_DEBUG:
		var __payload: Dictionary[String, Variant]
		__payload = {
			SPS.frame_field: u.sfr(),
			SPS.sig_name_field: str(signal_.get_name()),
			SPS.sig_with_payload_field: with_payload,
			SPS.sig_payload_field: payload
		}
		GlobalSignal.__SIG_sig_emitted.emit(__payload)


## returns true if emitted
static func safe_emit(
	signal_data: SignalData,
	signal_payload: Dictionary[String, Variant],
	__log: bool = false,
	warn_level: String = WL.INFO) -> bool:
	if error_.null_object(signal_data, "no signal data", warn_level):
		return false
	if error_.null_signal(signal_data.signal_obj, "", warn_level):
		return false
	__emit(signal_data.signal_obj, true, signal_payload)
	if __log:
		print_.prefix("<emit>", pp.sig(signal_data, signal_payload))
	return true


static func safe_emit_raw(
	signal_: Signal,
	signal_payload: Dictionary[String, Variant],
	__log: bool = false,
	warn_level: String = WL.INFO) -> bool:
	if error_.null_signal(signal_, "", warn_level):
		return false
	__emit(signal_, true, signal_payload)
	if __log:
		print_.prefix("<emit>", pp.sig_raw(signal_, signal_payload))
	return true

static func safe_emit_raw_toggle(
	signal_: Signal,
	toggle: bool,
	__log: bool = false,
	warn_level: String = WL.INFO) -> bool:
	return safe_emit_raw(signal_, {SPS.toggle_field: toggle})


static func safe_emit_raw_no_payload(
	signal_: Signal,
	__log: bool = false,
	warn_level: String = WL.INFO) -> bool:
	if error_.null_signal(signal_, "", warn_level):
		return false
	__emit(signal_, false, {})
	if __log:
		print_.prefix("<emit>", pp.sig_raw(signal_, {}))
	return true


static func safe_connect(
	signal_: Signal,
	callable: Callable,
	__log: bool = false,
	warn_level: String = WL.INFO) -> bool:
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
	warn_level: String = WL.INFO) -> bool:
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
	warn_level: String = WL.INFO):
	for pair: Array in pairs:
		if not _validate_signal_pair(pair, warn_level):
			continue
		safe_connect(pair[0], pair[1], __log, warn_level)
	

static func safe_disconnect_pairs(
	pairs: Array[Array],
	__log: bool = false,
	warn_level: String = WL.INFO):
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
		warn_level: String = WL.INFO
) -> RO.IntReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return RO.IntReturn.new(true)
		
	var payload_value = payload_value_return.value

	if not (payload_value is int):
		error_.warn("not (payload_value is int)", "", "", warn_level, payload, payload_key)
		return RO.IntReturn.new(true)

	return RO.IntReturn.new(false, payload_value)


## returns value as a float
static func safe_get_int_float_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.INFO
) -> RO.FloatReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return RO.FloatReturn.new(true)
		
	var payload_value = payload_value_return.value

	if not (payload_value is float or payload_value is int):
		error_.warn("not (payload_value is float or payload_value is int)", "", "", warn_level, payload, payload_key)
		return RO.FloatReturn.new(true)

	return RO.FloatReturn.new(false, float(payload_value))


static func safe_get_bool_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.INFO
) -> RO.BoolReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return RO.BoolReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is bool):
		error_.warn("not (payload_value is bool)", "", "", warn_level, payload, payload_key)
		return RO.BoolReturn.new(true)

	return RO.BoolReturn.new(false, payload_value)

static func safe_get_toggle_payload_value(
		payload: Dictionary[String, Variant],
		warn_level: String = WL.INFO
) -> RO.BoolReturn:
	var r := safe_get_bool_payload_value(payload, SPS.toggle_field)
	return r


static func safe_get_string_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		warn_level: String = WL.INFO
) -> RO.StringReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return RO.StringReturn.new(true)
	var payload_value = payload_value_return.value
	if not (payload_value is String):
		error_.warn("not (payload_value is String)", "", "", warn_level, payload, payload_key)
		return RO.StringReturn.new(true)

	return RO.StringReturn.new(false, payload_value)


static func safe_get_dict_payload_value(payload: Dictionary[String, Variant],
	payload_key: String,
	warn_level: String = WL.INFO
) -> RO.DictReturn:
	var payload_value_return := _get_value_by_key(payload, payload_key, false, warn_level)
	if payload_value_return.err:
		return RO.DictReturn.new(true, {})
	var payload_value = payload_value_return.value
	if not (payload_value is Dictionary):
		error_.warn("not (payload_value is Dictionary)", "", "", warn_level, payload, payload_key)
		return RO.DictReturn.new(true, {})

	return RO.DictReturn.new(false, payload_value)


static func safe_get_variant_payload_value(
		payload: Dictionary[String, Variant],
		payload_key: String,
		null_allowed: bool,
		warn_level: String = WL.INFO
) -> RO.VariantReturn:
	return _get_value_by_key(payload, payload_key, null_allowed, warn_level)


static func _get_value_by_key(
		payload: Dictionary[String, Variant],
		payload_key: String,
		null_allowed: bool = true,
		warn_level: String = WL.INFO
) -> RO.VariantReturn:
	if not DictUtils.safe_has_key(payload, payload_key, warn_level):
		return RO.VariantReturn.new(true)

	var payload_value = payload[payload_key]

	if not null_allowed and payload_value == null:
		error_.warn("not null_allowed and payload_value == null", "", "", warn_level, payload, payload_key)
		return RO.VariantReturn.new(true)

	return RO.VariantReturn.new(false, payload_value)
