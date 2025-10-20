extends BaseInterpolator
class_name FloatLinearInterpolator

var _start_value: float
var _target_value: float
var _current_value: float

## idempotent
func initialise(start: float, target: float, duration_: float) -> void:
	self._start_value = start
	self._target_value = target
	self._current_value = start

	self.duration = duration_
	self.timer = 0.0


## Returns _target_value when done
func update(delta: float) -> float:
	if timer < duration:
		timer += delta
		var weight = _get_progress()
		_current_value = lerp(_start_value, _target_value, weight)
	else:
		_current_value = _target_value

	return _current_value


func get_current_value() -> float:
	return _current_value