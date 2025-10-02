extends RefCounted
class_name CurveInterpolator

var curve: Curve
var progress: float = 0.0
var duration: float = 1.0
var timer: float = 0.0
var _completed: bool = false

## idempotent
func initialise(curve_: Curve, duration_: float) -> void:
	assert(curve_)

	curve = curve_
	duration = duration_
	progress = 0.0
	timer = 0.0
	_completed = false

func update(delta: float) -> float:
	if timer < duration:
		timer += delta
		progress = clampf(timer / duration, 0.0, 1.0)
	else:
		progress = 1.0
		_completed = true
	
	return curve.sample(progress)

func get_progress() -> float:
	return progress

func is_complete() -> bool:
	return _completed

func reset() -> void:
	timer = 0.0
	progress = 0.0
	_completed = false

# optional: force jump to specific progress
func set_progress(percentage: float) -> void:
	progress = clampf(percentage, 0.0, 1.0)
	timer = progress * duration
	_completed = (progress >= 1.0)