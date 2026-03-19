## its actually more like evaluator: just returning raw curve data
class_name EaseCurveInterpolator
extends BaseInterpolator


var curve: Curve


## idempotent
func initialize(curve_: Curve, duration_: float) -> void:
	assert(curve_)
	self.curve = curve_
	self.duration = duration_
	self.timer = 0.0


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

## Sample curve at specific progress (0.0 to 1.0)
## Example: for animation speed scaling: 
	## sample_at_progress(anim.current_animation_position / anim.current_animation_length)
func sample_at_progress(progress: float) -> float:
	return curve.sample(clampf(progress, 0.0, 1.0))