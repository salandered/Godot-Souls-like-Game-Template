extends RefCounted
class_name error_


static func _warn(_msg: String, warn_level: String = WarnLevel.PUSH_ERROR):
	_msg = pp.s(em.warn, "WARNING |", _msg)
	var _msg_crucial = pp.s(em.crucial_x2, _msg)
	match warn_level:
		## soft equals warn here
		WarnLevel.SILENT:
			pass
		WarnLevel.WARN:
			print("\t", _msg)
		WarnLevel.WARN_CRUCIAL:
			print("\t", _msg_crucial)
		WarnLevel.ASSERT:
			push_error(_msg_crucial) # important!
			assert(false, _msg_crucial)
		WarnLevel.PUSH_ERROR:
			push_error(_msg_crucial)
		WarnLevel.PUSH_WARNING:
			push_warning(_msg)
		_:
			prints("\t", em.crucial_x2, "Unknown warn level!", pp.in_q(warn_level), "Will be treated as PUSH_ERROR")
			push_error(_msg_crucial)


static func warn(
		what: String,
		where: String,
		fallback: String,
		warn_level: String = WarnLevel.PUSH_ERROR,
		...details: Array):
	var _msg = "Problem: %s. Where: '%s'. Fallback '%s'. [%s]" % [what, where, fallback, warn_level]
	if not details.is_empty():
		_msg += "| Details: " + pp.list_(details)
	_warn(_msg, warn_level)


## ERROR HELPERS
# returns True if error caught
# return False if it's fine
# minimal arguments and context
# used when expected False in all sane scenarios


static func empty_string(
		string_: String,
		warn_level: String = WarnLevel.PUSH_ERROR,
) -> bool:
	if not string_.is_empty():
		return false
	var _msg := "Problem: String is empty"
	_warn(_msg, warn_level)
	return true


static func empty_list(
		list_: Array,
		context: String = "",
		warn_level: String = WarnLevel.PUSH_ERROR,
) -> bool:
	if not list_.is_empty():
		return false
	var _msg := pp.s("Problem: Array is empty", context)
	_warn(_msg, warn_level)
	return true


static func null_object(
		object_: Object,
		context: String = "",
		warn_level: String = WarnLevel.PUSH_ERROR,
) -> bool:
	if not object_:
		var _msg := pp.s("Problem: object is null", context)
		_warn(_msg, warn_level)
		return true
	return false


static func null_signal(
		signal_data: SignalData,
		## i think null signal is less important
		## if its null, it won't be emitted, that's all
		warn_level: String = WarnLevel.WARN_CRUCIAL,
) -> bool:
	if not signal_data:
		return true
	if signal_data.signal_obj.is_null():
		var _msg := pp.s("Problem: signal_.is_null true", signal_data)
		_warn(_msg, warn_level)
		return true
	return false
