extends RefCounted
class_name CurveInterpolator

var curve: Curve
var progress: float = 0.0
var duration: float = 1.0
var timer: float = 0.0

## idempotent
func initialise(curve_: Curve, duration_: float) -> void:
	assert(curve_)
	curve = curve_
	duration = duration_
	progress = 0.0
	timer = 0.0

## Returns final curve value when done
func update(delta: float) -> float:
	if timer < duration:
		timer += delta
		progress = clampf(timer / duration, 0.0, 1.0)
	else:
		progress = 1.0
	
	return curve.sample(progress)

func get_progress() -> float:
	return progress

func reset() -> void:
	timer = 0.0
	progress = 0.0