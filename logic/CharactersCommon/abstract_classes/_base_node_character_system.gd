@abstract
class_name BaseNodeCharacterSystem
extends Node


@abstract func is_player() -> bool


## pretty system name
## Basic use case: prefix for logging. 
## Should not be treated as ID in any sense! It's just cosmetics.
@abstract func pp_name() -> String


# region __LOGS

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