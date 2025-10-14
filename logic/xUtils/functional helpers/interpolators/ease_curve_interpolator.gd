extends BaseInterpolator
## its actually more like evaluator: just returning raw curve data
class_name EaseCurveInterpolator

var curve: Curve

## idempotent
func initialise(curve_: Curve, duration_: float) -> void:
	assert(curve_)
	curve = curve_
	duration = duration_
	timer = 0.0


## Returns final curve value when done
## Essentially returns 'curved' progress, so result is [0, 1].
func update(delta: float) -> float:
	var curr_progress: float
	if timer < duration:
		timer += delta
		curr_progress = _get_progress()
	else:
		curr_progress = 1.0
	
	return curve.sample(curr_progress)
