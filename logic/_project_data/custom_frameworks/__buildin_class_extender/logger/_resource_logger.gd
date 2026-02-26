@abstract
class_name ResourceLogger
extends Resource


## __LOGS [same for loggers]
# region

func pp_name() -> String:
	return ObjUtils.construct_obj_pp_name(self )

## to override
func __LOG_B() -> bool:
	return true

## to override
func __LOG_INDENT() -> int:
	return 0


func __log_(_prefix: Variant, ...parts: Array):
	LoggingFramework.for_log_(self , _prefix, pp.list_(parts))

func __log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array):
	LoggingFramework.for_log_warn_soft(self , what, where, fallback, pp.list_(context))

func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	LoggingFramework.for_log_warn(self , what, where, fallback, pp.list_(context))

func __log_error(what: String, where: String = "", fallback: String = "", ...context: Array):
	LoggingFramework.for_log_error(self , what, where, fallback, pp.list_(context))

# endregion

# --------------------------------------------------------------------------

# TEMPLATE paste and uncomment [same for loggers]

# ## __LOGS
# # region

# func pp_name() -> String:
# 	return "if u want specific"

# func __LOG_B() -> bool:
# 	return true

# func __LOG_INDENT() -> int:
# 	return 0

# # endregion