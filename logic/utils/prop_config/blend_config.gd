class_name BlendConfig
extends RefCounted


var fade_in: float # in seconds
var fade_out: float # in seconds
## seconds at full _weight
## if not set (-1.0), will be calculated using anim dur, and fade in/out
var hold: float


func _init(fade_in_: float = 0.2, fade_out_: float = 0.2, hold_: float = -1.0) -> void:
	self.fade_in = fade_in_
	self.fade_out = fade_out_
	self.hold = hold_


func auto_fade_in_out_calibrate(duration: float, scale: float = 0.6):
	if fade_in + fade_out > scale * duration:
		fade_in = scale / 2 * duration
		fade_out = scale / 2 * duration


func auto_hold_calibrate(duration: float, max_possible_hold: bool = false):
	if max_possible_hold:
		hold = max(0.0, duration - fade_in - fade_out)
	else:
		if hold == -1.0 or hold + fade_in + fade_out > duration:
			hold = max(0.0, duration - fade_in - fade_out)


func get_calibrated_hold(duration: float):
	if hold == -1.0 or hold + fade_in + fade_out > duration:
		return max(0.0, duration - fade_in - fade_out)
	else:
		return hold

## if max_possible_hold is false, fade in + fade out + hold <= duration. Can be less if hold already set to ok value
func auto_calibrate(duration: float, max_possible_hold: bool = false, scale: float = 0.6):
	auto_fade_in_out_calibrate(duration, scale)
	auto_hold_calibrate(duration, max_possible_hold)


func _to_string() -> String:
	return "BlendCfg(fade_in/out %s/%s hold %s)" % [pp.s(fade_in), pp.s(fade_out), pp.s(hold)]
