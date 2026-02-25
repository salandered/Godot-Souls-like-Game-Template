extends RefCounted
class_name error_


## printer with specific detailed formatting.
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

	print_err.msg_formatted(_msg, warn_level)


## ERROR UTILS
# - name is positive condition
# - treats as error if name (positive condition) is valid
# - returns True if error caught
# - minimal arguments and context
# - is used when expected False


## allows StringName
static func empty_string(
		string_: Variant,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if null_variant(string_, context, warn_level):
		return true
	if string_ is not String and string_ is not StringName:
		print_err.msg_formatted(_err_msg("not String/StringName", context), warn_level)
		return true
	if string_.is_empty():
		print_err.msg_formatted(_err_msg("String is empty", context), warn_level)
		return true
	return false


static func empty_list(
	list_: Variant,
	context: String = "",
	warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	return _check_list_len(list_, 0, "Array is empty", context, warn_level)


static func one_len_list(
	list_: Variant,
	context: String = "",
	warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	return _check_list_len(list_, 1, "Array len is one", context, warn_level)


static func null_object(
		object_: Object,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if object_ == null:
		print_err.msg_formatted(_err_msg("object is null", context), warn_level)
		return true
	return false


static func null_variant(
		variant_: Variant,
		context: String = "",
		warn_level: StringName = WL.PUSH_ERROR,
) -> bool:
	if variant_ == null:
		print_err.msg_formatted(_err_msg("variant_ is null", context), warn_level)
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
		print_err.msg_formatted(_err_msg("signal_.is_null true", context), warn_level)
		return true
	return false


static func _check_list_len(
	list_: Variant,
	target_len: int,
	len_msg: String,
	context: String,
	warn_level: StringName
) -> bool:
	if null_variant(list_, context, warn_level):
		return true
	## WARNING: currently Packed Arrays are not widely used in project. But this should be extended
	if list_ is not Array and list_ is not PackedStringArray:
		print_err.msg_formatted(_err_msg("not Array", context), warn_level)
		return true
	if len(list_) == target_len:
		print_err.msg_formatted(_err_msg(len_msg, context), warn_level)
		return true
	return false


static func _err_msg(problem: String, context: String = "", ...parts: Array) -> String:
	var context_msg := "" if context.is_empty() else pp.s("| Context:", context)
	return pp.s("Problem:", problem, context_msg, "|", pp.list_(parts))
