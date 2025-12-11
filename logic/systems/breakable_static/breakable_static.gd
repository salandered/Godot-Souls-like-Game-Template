@abstract
class_name BreakableStatic
extends BaseStaticBody3DSystem

## use initialise instead of _ready for heirs

func _ready() -> void:
	initialise()


@abstract func initialise() -> void


@abstract func _is_breakable() -> bool


@abstract func break_myself() -> void


## __LOGS
# region

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion