@abstract
class_name RefCountedLogger
extends RefCounted


## pretty name
## Basic use case: prefix for logging. 
@abstract func pp_name() -> String


## are logs turned on. warn logs are always turned on.
@abstract func __LOG_B() -> bool

## just indent 
@abstract func __LOG_INDENT() -> int


func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B():
		print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), 10)

func __log_warn(crucial: bool, what: String, where: String, fallback: String, ...context: Array):
	print_.warn(crucial, what, pp.s(pp_name(), "|", where), fallback, pp.list_(context))

# endregion


# copy paste it around abstract implementations

## __LOGS
# region

# endregion
