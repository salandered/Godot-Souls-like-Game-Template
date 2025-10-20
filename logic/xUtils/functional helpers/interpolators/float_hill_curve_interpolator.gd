extends BaseInterpolator

class_name HillInterpolator

var start_value: float
var end_value: float
var peak_value: float
var curve: Curve # "hill" curve - Y-values 0.0 to 1.0
var current_value: float

## idempotent
func initialise(start: float, end: float, peak: float, curve_: Curve, duration_: float) -> void:
	assert(curve_)
	start_value = start
	end_value = end
	peak_value = peak
	curve = curve_
	duration = duration_
	timer = 0.0
	current_value = start_value
	print_.prefix("HillInterpolator",
		pp.s("Init: start", start_value, "end", end_value, "peak", peak_value, "dur", duration), 7)

## Returns end_value when done
func update(delta: float) -> float:
	if timer < duration:
		timer += delta
		var raw_progress := _get_progress()
		
		var base_value := lerpf(start_value, end_value, raw_progress)
		var burst_factor := curve.sample(raw_progress)
		current_value = lerpf(base_value, peak_value, burst_factor)

	else:
		current_value = end_value

	return current_value
