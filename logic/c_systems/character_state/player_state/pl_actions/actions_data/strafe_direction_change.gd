extends RefCounted
class_name StrafeDirChange


# can we make an opposite change at all
var cooldown := SimpleTimer.new()
# postpone the opposite change
var async_change := DelayCallbackTimer.new()
var speed_dip := EaseCurveInterpolator.new()
var speed_dip_curve: Curve

var DURATION: float
var dip_time_ratio: float


func initialise(curve: Curve, duration: float, curve_bottom_point_idx: int = -1):
	speed_dip_curve = curve
	DURATION = duration

	cooldown.initialise(DURATION) # probably safer to use same time as in async_change
	if curve_bottom_point_idx == -1:
		dip_time_ratio = 0.5
	else:
		# correct curve_bottom_point_idx is important. usually 1 or 2. (they start from 0)
		dip_time_ratio = tu.get_curve_point_x(curve, curve_bottom_point_idx)
	# print_.note(false, "StrafeDirChange init", "note the dip_time_ratio:", dip_time_ratio)


func speed_dip_update(delta: float) -> float:
	if speed_dip.is_in_progress():
		return speed_dip.update(delta)
	return 1.0


func async_change_update(delta: float):
	if async_change.is_in_progress():
		async_change.update(delta)


func async_change_init(callback: Callable):
	async_change.initialise(DURATION * dip_time_ratio, callback)


func speed_dip_init():
	speed_dip.initialise(speed_dip_curve, DURATION)


func reset():
	cooldown.reset()
	async_change.reset()
	speed_dip.reset()
