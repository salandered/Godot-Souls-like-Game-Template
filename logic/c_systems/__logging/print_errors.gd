extends RefCounted
class_name error_


static func warn(
		what: String,
		where: String,
		fallback: String,
		warn_level: StringName = WL.PUSH_ERROR,
		...details: Array):
	if warn_level == WL.SILENT: return

	var _msg := pp.s("Problem:", what)

	where = where.strip_edges()
	fallback = fallback.strip_edges()
	if not where.is_empty():
		_msg += pp.s(". Where:", where)
	if not fallback.is_empty():
		_msg += pp.s(". Fallback:", fallback)
	if not details.is_empty():
		_msg += " | Details: " + pp.list_(details)
	_msg += pp.in_sq(warn_level)

	_low_level_printer._warn(_msg, warn_level)


## ERROR HELPERS
# returns True if error caught
# return False if it's fine
# minimal arguments and context
# used when expected False in all sane scenarios


## allows StringName
static func empty_string(
		string_: Variant,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if null_variant(string_, context, warn_level):
		return true
	if string_ is not String and string_ is not StringName:
		_low_level_printer._warn(_err_msg("not String/StringName", context), warn_level)
		return true
	if string_.is_empty():
		_low_level_printer._warn(_err_msg("String is empty", context), warn_level)
		return true
	return false


static func empty_list(
		list_: Variant,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if null_variant(list_, context, warn_level):
		return true
	if list_ is not Array and list_ is not PackedStringArray:
		_low_level_printer._warn(_err_msg("not Array", context), warn_level)
		return true
	if list_.is_empty():
		_low_level_printer._warn(_err_msg("Array is empty", context), warn_level)
		return true
	return false


static func null_object(
		object_: Object,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if object_ == null:
		_low_level_printer._warn(_err_msg("object is null", context), warn_level)
		return true
	return false


static func null_variant(
		variant_: Variant,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if variant_ == null:
		_low_level_printer._warn(_err_msg("variant_ is null", context), warn_level)
		return true
	return false


static func null_signal(
		signal_: Signal,
		context: String = "",
		## i think null signal is less important
		## if its null, it won't be emitted, that's all
		warn_level: StringName = WL.WARN_CRUCIAL,
) -> bool:
	if signal_.is_null():
		_low_level_printer._warn(_err_msg("signal_.is_null true", context), warn_level)
		return true
	return false


static func len_one(
		list_: Variant,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if null_variant(list_, context, warn_level):
		return true
	if list_ is not Array:
		_low_level_printer._warn(_err_msg("not Array", context), warn_level)
		return true
	if len(list_) != 1:
		_low_level_printer._warn(_err_msg(pp.s("Len is not 1:", len(list_)), context), warn_level)
		return true
	return false


static func _err_msg(problem: String, context: String = "", ...parts: Array) -> String:
	var context_msg := "" if context.is_empty() else pp.s("| Context:", context)
	return pp.s("Problem:", problem, context_msg, "|", pp.list_(parts))
