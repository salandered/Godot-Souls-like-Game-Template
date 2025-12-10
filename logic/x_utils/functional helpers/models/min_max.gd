extends BaseRefCountedSystem
class_name FMinMax


var min_: float
var max_: float


func _init(min__: float, max__: float):
	min_ = min__
	max_ = max__


func clamp(value: float, __log: bool = false, context: String = "") -> float:
	if is_in_range(value):
		return value
	if __log:
		__log_("Clamp", "Clamping value", value, "to range", pp_min_max(), pp.in_q(context))
	return clampf(value, min_, max_)


## inclusive
func is_in_range(value: float) -> bool:
	return value >= min_ and value <= max_


func pp_min_max() -> String:
	return pp.in_sq(pp.s(min_, max_))


## __LOGS
# region

func pp_name() -> String:
	return "FMinMax"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion