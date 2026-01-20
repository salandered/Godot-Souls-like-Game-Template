class_name ExtenderLogger
extends RefCounted ## dont use Extender here ...

const PP_NAME_NAME = "pp_name"
const LOG_B_NAME = "__LOG_B"
const LOG_INDENT_NAME = "__LOG_INDENT"


static func for_log_(object_: Object, prefix: Variant, ...parts: Array) -> void:
	if not OS.is_debug_build():
		return
	if u.safe_has_method(object_, LOG_B_NAME, WL.WARN) \
		and u.safe_has_method(object_, PP_NAME_NAME, WL.WARN) \
		and u.safe_has_method(object_, LOG_INDENT_NAME, WL.WARN):
		if object_.__LOG_B():
			print_.prefix(pp.s(object_.pp_name(), prefix), pp.list_(parts), object_.__LOG_INDENT())
	else:
		error_.warn(pp.s("ExtenderLogger only support objects with methods:", PP_NAME_NAME, LOG_B_NAME, LOG_INDENT_NAME), "", "", WL.WARN)


static func for_log_warn_soft(object_: Object, what: String, where: String, fallback: String, context: String) -> void:
	_for_log_warn(WL.WARN, object_, what, where, fallback, context)


static func for_log_warn(object_: Object, what: String, where: String, fallback: String, context: String) -> void:
	_for_log_warn(WL.PUSH_WARN, object_, what, where, fallback, context)


static func for_log_error(object_: Object, what: String, where: String, fallback: String, context: String) -> void:
	_for_log_warn(WL.PUSH_ERROR, object_, what, where, fallback, context)


static func _for_log_warn(
		warn_level: String,
		object_: Object,
		what: String,
		where: String,
		fallback: String,
		context: String
) -> void:
	if u.safe_has_method(object_, PP_NAME_NAME, WL.WARN):
		error_.warn(what, pp.s(object_.pp_name(), "|", where), fallback, warn_level, context)
	else:
		error_.warn(pp.s("ExtenderLogger only support objects with methods:", PP_NAME_NAME), "", "", WL.WARN)


## for static

static func for_static_log_warn_soft(what: String, where: String, fallback: String, context: String):
	_for_static_log_warn(WL.WARN, what, where, fallback, context)

static func for_static_log_warn(what: String, where: String, fallback: String, context: String):
	_for_static_log_warn(WL.PUSH_WARN, what, where, fallback, context)

static func for_static_log_warn_assert(what: String, where: String, fallback: String, context: String):
	_for_static_log_warn(WL.ASSERT, what, where, fallback, context)

static func for_static_log_error(what: String, where: String, fallback: String, context: String):
	_for_static_log_warn(WL.PUSH_ERROR, what, where, fallback, context)


static func _for_static_log_warn(
		warn_level: String,
		what: String,
		where: String,
		fallback: String,
		context: String
) -> void:
	error_.warn(what, pp.s("Static", "|", where), fallback, warn_level, context)
