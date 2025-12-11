@abstract
class_name BaseSkModifier3DSystem
extends SkeletonModifier3D

## INITIALISATION (OPTIONAL)
# region

var __initialised: bool = false


func __could_not_initialised() -> bool:
	return not __initialised


func __validate_deps_set_init() -> bool:
	var _r := ValidateDependencies.validate_deps_and_set_init_true(self)
	return _r


## returns the result of validation
## NOTE: returns true if only hard deps were met
func __validate_dependencies() -> bool:
	var _r := ValidateDependencies.validate_dependencies(self)
	return _r


func __set_initialised_true() -> bool:
	var _r := ValidateDependencies.set_initialised_true(self)
	return _r


func get_hard_dependencies() -> Array[Object]:
	return []

func get_soft_dependencies() -> Array[Object]:
	return []

# endregion


## __LOGS [same for all similar extenders]
# region

func pp_name() -> String:
	return u.object_pp_name(self)

@abstract func __LOG_B() -> bool

@abstract func __LOG_INDENT() -> int


func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B():
		print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), 10)

func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WL.PUSH_WARN, pp.list_(context))

func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WL.PUSH_ERROR, pp.list_(context))

# endregion


# TEMPLATE 
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