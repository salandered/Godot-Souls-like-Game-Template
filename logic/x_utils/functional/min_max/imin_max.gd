extends RefCountedLogger
class_name IMinMax


var min_: int
var max_: int


func _init(min__: int, max__: int):
	min_ = min__
	max_ = max__


func clamp(value: int, __log: bool = false, context: String = "") -> int:
	if is_in_range(value):
		return value
	if __log:
		__log_("Clamp", "Clamping value", value, "to range", pp_min_max(), pp.in_q(context))
	return clampi(value, min_, max_)


## inclusive
func is_in_range(value: int) -> bool:
	return value >= min_ and value <= max_


func pp_min_max() -> String:
	return pp.in_sq(pp.s(min_, max_))
