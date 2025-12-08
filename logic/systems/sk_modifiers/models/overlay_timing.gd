extends RefCounted
class_name OverlayTiming


var fade_in: float
var hold: float
var fade_out: float
var weight: float
var hips_weight: float


func _init(anim_dur_: float, overlay_config: OverlayConfig):
	self.fade_in = max(overlay_config.get_fade_in(), 0.01)
	if overlay_config.get_hold() == -1.0:
		self.hold = overlay_config._blend.get_calibrated_hold(anim_dur_)
	else:
		self.hold = overlay_config.get_hold()
	self.fade_out = max(overlay_config.get_fade_out(), 0.01)
	self.weight = overlay_config.get_weight()
	self.hips_weight = overlay_config.get_hips_weight()


func get_total_duration() -> float:
	return fade_in + hold + fade_out


func get_weight_at_time(time_spent: float) -> float:
	return _get_weight_curve(time_spent, weight)


func get_hips_weight_at_time(time_spent: float) -> float:
	return _get_weight_curve(time_spent, hips_weight)


func _get_weight_curve(time_spent: float, target_weight: float) -> float:
	if time_spent < fade_in:
		return (time_spent / fade_in) * target_weight
	elif time_spent < fade_in + hold:
		return target_weight
	elif time_spent < get_total_duration():
		return target_weight * (1.0 - (time_spent - fade_in - hold) / fade_out)
	else:
		return 0.0

func _to_string() -> String:
	return "OverlTmg[w/wh:%.1f/%.1f, in:%.1f, hold:%.1f, out:%.1f, total:%.1f]" % [weight, hips_weight, fade_in, hold, fade_out, get_total_duration()]
