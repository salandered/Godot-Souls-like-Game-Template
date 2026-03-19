class_name EaseCurveSampler


var curve: Curve


func initialize(curve_: Curve) -> void:
	assert(curve_)
	self.curve = curve_


## Sample curve at specific progress (0.0 to 1.0)
## Example: for animation speed scaling: 
	## sample_at_progress(anim.current_animation_position / anim.current_animation_length)
func sample_at_progress(progress: float) -> float:
	return curve.sample(clampf(progress, 0.0, 1.0))
