extends RefCounted
class_name error_


static var _last_warn_msg = ""

static func _warn(warn_msg: String, warn_level: String = WL.PUSH_ERROR):
	if warn_level == WL.SILENT: return

	warn_msg = pp.s(em.warn, "WARNING |", warn_msg)


	if warn_msg == _last_warn_msg:
		log.prefix_s(false, "\t\t |", warn_msg, "same message again")
		return
	_last_warn_msg = warn_msg

	match warn_level:
		## soft equals warn here
		WL.SILENT:
			pass
		WL.WARN:
			log.prefix_s(true, "\t", warn_msg)
		WL.WARN_CRUCIAL:
			log.prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
		WL.ASSERT:
			log.prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_error(pp.s(em.crucial_x2, warn_msg)) # important!
			assert(false, pp.s(em.crucial_x2, warn_msg))
		WL.PUSH_ERROR:
			log.prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_error(pp.s(em.crucial_x2, warn_msg))
		WL.PUSH_WARN:
			log.prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_warning(warn_msg)
		_:
			log.prefix_s(true, "\t", em.crucial_x2, "Unknown warn level!", pp.in_q(warn_level), "Will be treated as PUSH_ERROR")
			log.prefix_s(true, "\t", pp.s(em.crucial_x2, warn_msg))
			push_error(pp.s(em.crucial_x2, warn_msg))


static func warn(
		what: String,
		where: String,
		fallback: String,
		warn_level: String = WL.PUSH_ERROR,
		...details: Array):
	if warn_level == WL.SILENT: return

	var _msg = pp.s("Problem:", what)

	where = where.strip_edges()
	fallback = fallback.strip_edges()
	if not where.is_empty():
		_msg += pp.s(". Where:", where)
	if not fallback.is_empty():
		_msg += pp.s(". Fallback:", fallback)
	if not details.is_empty():
		_msg += " | Details: " + pp.list_(details)
	_msg += pp.in_sq(warn_level)

	_warn(_msg, warn_level)


## ERROR HELPERS
# returns True if error caught
# return False if it's fine
# minimal arguments and context
# used when expected False in all sane scenarios


static func empty_string(
		string_: Variant,
		context: String = "",
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if null_variant(string_, context, warn_level):
		return true
	if string_ is not String:
		_warn(_err_msg("not String", context), warn_level)
		return true
	if string_.is_empty():
		_warn(_err_msg("String is empty", context), warn_level)
		return true
	return false


static func empty_list(
		list_: Variant,
		context: String = "",
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if null_variant(list_, context, warn_level):
		return true
	if list_ is not Array and list_ is not PackedStringArray:
		_warn(_err_msg("not Array", context), warn_level)
		return true
	if list_.is_empty():
		_warn(_err_msg("Array is empty", context), warn_level)
		return true
	return false


static func null_object(
		object_: Object,
		context: String = "",
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if object_ == null:
		_warn(_err_msg("object is null", context), warn_level)
		return true
	return false


static func null_variant(
		variant_: Variant,
		context: String = "",
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if variant_ == null:
		_warn(_err_msg("variant_ is null", context), warn_level)
		return true
	return false


static func null_signal(
		signal_data: SignalData,
		context: String = "",
		## i think null signal is less important
		## if its null, it won't be emitted, that's all
		warn_level: String = WL.WARN_CRUCIAL,
) -> bool:
	if null_object(signal_data, context, warn_level):
		return true
	if signal_data.signal_obj.is_null():
		_warn(_err_msg("signal_obj.is_null true", context, signal_data), warn_level)
		return true
	return false


static func len_one(
		list_: Variant,
		context: String = "",
		warn_level: String = WL.PUSH_ERROR,
) -> bool:
	if null_variant(list_, context, warn_level):
		return true
	if list_ is not Array:
		_warn(_err_msg("not Array", context), warn_level)
		return true
	if len(list_) != 1:
		_warn(_err_msg(pp.s("Len is not 1:", len(list_)), context), warn_level)
		return true
	return false


static func _err_msg(problem: String, context: String = "", ...parts: Array) -> String:
	var context_msg := "" if context.is_empty() else pp.s("| Context:", context)
	return pp.s("Problem:", problem, context_msg, "|", pp.list_(parts))
