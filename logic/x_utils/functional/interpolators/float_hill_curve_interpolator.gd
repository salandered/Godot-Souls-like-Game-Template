class_name HillInterpolator
extends BaseInterpolator


var start_value: float
var end_value: float
var peak_value: float
var curve: Curve # "hill" curve - Y-values 0.0 to 1.0
var current_value: float


## idempotent
func initialise(start: float, end: float, peak: float, curve_: Curve, duration_: float) -> void:
	assert(curve_)
	self.start_value = start
	self.end_value = end
	self.peak_value = peak
	self.curve = curve_
	self.duration = duration_
	self.timer = 0.0
	self.current_value = start_value
	# print_.dev("HillInterpolator",
		# "Init: start", start_value, "end", end_value, "peak", peak_value, "dur", duration)


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
