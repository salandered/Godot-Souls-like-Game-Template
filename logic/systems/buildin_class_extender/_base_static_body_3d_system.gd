@abstract
class_name BaseStaticBody3DSystem
extends StaticBody3D


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
