class_name EaseCurveSampler

var curve: Curve

func initialise(curve_: Curve) -> void:
	assert(curve_)
	curve = curve_


## Sample curve at specific progress (0.0 to 1.0)
## Example: for animation speed scaling: 
	## sample_at_progress(anim.current_animation_position / anim.current_animation_length)
func sample_at_progress(progress: float) -> float:
	return curve.sample(clampf(progress, 0.0, 1.0))
