@abstract
class_name RefCountedStaticLogger
extends RefCounted


## __LOGS [Common for static extenders]
# region

#---------------------------------------

## TEMPLATE TO ADD

## region: __LOGS
# static func pp_name() -> String:
# 	return ""

# static func __LOG_B() -> bool:
# 	return true

# static func __LOG_INDENT() -> int:
# 	return 10

# static func __log_(_prefix: Variant, ...parts: Array):
	# if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

## endregion

#---------------------------------------

## example usage of functions:

# if __LOG_B(): __log_(pp_name(), "usual log")


# --------------------------------------

## will be used if template not added, as a fallback

static func __LOG_B() -> bool:
	return true

static func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_STATIC_REF_C_INDENT
	
# --------------------------------------

## this functions are used the same as with not static extenders 
#  (can be used without template)

static func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(where), fallback, WL.PUSH_WARN, pp.list_(context))

static func __log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(where), fallback, WL.WARN, pp.list_(context))

static func __log_warn_assert(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(where), fallback, WL.ASSERT, pp.list_(context))

static func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(where), fallback, WL.PUSH_ERROR, pp.list_(context))

# endregion
