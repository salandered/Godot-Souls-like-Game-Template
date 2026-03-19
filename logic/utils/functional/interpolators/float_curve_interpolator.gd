extends BaseInterpolator
class_name FloatCurveInterpolator


## gets the linear progress by _get_progress() -> raw progress (0.0 to 1.0) 
## uses curve.sample to find the corresponding point -> eased progress (0.0 to 1.0) 
## uses lerp() with eased progress to find the actual value between start and target values
## With start = 0 and target = 1 its identical to EaseCurveInterpolator


var start_value: float
var target_value: float
var current_value: float
var curve: Curve


## idempotent
func initialize(start: float, target: float, curve_: Curve, duration_: float) -> void:
	assert(curve_)
	self.start_value = start
	self.target_value = target
	self.current_value = start
	self.curve = curve_
	self.duration = duration_
	self.timer = 0.0


## Returns target_value when done
func update(delta: float) -> float:
	if timer < duration:
		timer += delta
		var raw_progress := _get_progress()
		var eased_progress := curve.sample(raw_progress)
		current_value = lerp(start_value, target_value, eased_progress)
	else:
		current_value = target_value

	return current_value