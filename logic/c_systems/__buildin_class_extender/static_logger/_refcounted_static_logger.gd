@abstract
class_name RefCountedStaticLogger
extends RefCounted


## __LOGS [Common for static extenders]
# region

#---------------------------------------


## TEMPLATE TO ADD

## region: __LOGS
# static func pp_name() -> String:
# 	return "something"

# static func __LOG_B() -> bool:
# 	return true

# static func __log_(_prefix: Variant, ...parts: Array):
	# if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

## endregion

static func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_STATIC_INDENT

# --------------------------------------

## this functions are used the same as with not static extenders 
#  (can be used without template, but lacks pp_name)

static func __log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array):
	ExtenderLogger.for_static_log_warn_soft(what, where, fallback, pp.list_(context))

static func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	ExtenderLogger.for_static_log_warn(what, where, fallback, pp.list_(context))


static func __log_warn_assert(what: String, where: String = "", fallback: String = "", ...context: Array):
	ExtenderLogger.for_static_log_warn_assert(what, where, fallback, pp.list_(context))

static func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	ExtenderLogger.for_static_log_error(what, where, fallback, pp.list_(context))

# endregion
