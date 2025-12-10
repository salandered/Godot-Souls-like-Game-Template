@abstract
class_name BaseRefCountedSystem
extends RefCounted


func __validate_dependencies() -> bool:
	var _r := ValidateDependencies.validate_dependencies(self)
	return _r


func get_hard_dependencies() -> Array[Object]:
	return []

func get_soft_dependencies() -> Array[Object]:
	return []


## __LOGS [same for all similar extenders]
# region

@abstract func pp_name() -> String
 
@abstract func __LOG_B() -> bool

@abstract func __LOG_INDENT() -> int


func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B():
		print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), 10)

func __log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.WARN, pp.list_(context))

func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_WARNING, pp.list_(context))

func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_ERROR, pp.list_(context))

# endregion

# ---------------------------------------------------------

# ## TEMPLATE
# paste and uncomment this for faster set up [same for all similar extenders]


# ## __LOGS
# # region

# func pp_name() -> String:
# 	return ""

# func __LOG_B() -> bool:
# 	return true

# func __LOG_INDENT() -> int:
# 	return 0

# # endregion