extends Resource
class_name Trait

var name: String
var value: float
var min_: float
var max_: float
var step: float
var default: float

func _init(_name: String, _value: float, _min: float, _max: float, _step: float, _default: float):
	name = _name
	value = _value
	min_ = _min
	max_ = _max
	step = _step
	default = _default


## from 0 to 1
func normalized() -> float:
	if max_ == min_:
		return 0.0
	return (value - min_) / (max_ - min_)
