@abstract
class_name RefCountedStaticLogger
extends RefCounted


## __LOGS [Common for static extenders]
# region

static func pp_name() -> String:
	return "forgot-to-set"

static func __LOG_B() -> bool:
	return true

static func __LOG_INDENT() -> int:
	return 0


static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B():
		print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), 10)

static func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	print_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_WARNING, pp.list_(context))

static func __log_warn_assert(what: String, where: String = "", fallback: String = "", ...context: Array):
	print_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.ASSERT, pp.list_(context))

static func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	print_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_ERROR, pp.list_(context))

# endregion
