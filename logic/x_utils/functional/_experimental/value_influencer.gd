class_name ValueInfluencer
extends RefCounted

var _influencer_name: String
var default_target_multiplier: float

var default_blend: BlendConfig
var current_blend: BlendConfig

func _init(target_multiplier_: float = 0.8, influencer_name_: String = "not set") -> void:
	assert(target_multiplier_ >= 0.0, "Target multiplier should be non-negative")
	self.default_target_multiplier = target_multiplier_
	self._influencer_name = influencer_name_
	self.default_blend = BlendConfig.new(0.1, 0.1)


func set_default_target_multiplier(target_multiplier_: float):
	self.default_target_multiplier = target_multiplier_


func influence_value(value: float, timer: SimpleTimer, override_multiplier: float = -1.0) -> float:
	if not timer.is_in_progress():
		return value

	var timer_duration := timer.duration
	
	## could be cache for calibrated current_blend {timer.duration: BlendConfig} if perf problems
	current_blend = BlendConfig.new(default_blend.fade_in, default_blend.fade_out, default_blend.hold)
	current_blend.auto_calibrate(timer_duration, true)
	__log_(current_blend)
	
	var multiplier: float = default_target_multiplier
	if override_multiplier != -1.0:
		multiplier = override_multiplier

	var result_multiplier := _get_multiplier(timer, multiplier)
	var result := value * result_multiplier
	
	__log_("Val", value, "->", result, "| Mult", result_multiplier, "Elapsed", timer.get_elapsed(), "/", timer_duration)
	
	return result


func _get_multiplier(timer: SimpleTimer, target_mult: float) -> float:
	var total_duration := timer.duration
	var elapsed_time := timer.get_elapsed()

	if elapsed_time < current_blend.fade_in:
		var t := elapsed_time / current_blend.fade_in
		var eased_t := ease_in_out(t)
		var result := lerpf(1.0, target_mult, eased_t)
		__log_("Phase: FADE_IN", "t", t, "-> eased", eased_t, "-> mult", result)
		return result

	elif elapsed_time < current_blend.fade_in + current_blend.hold:
		__log_("Phase: HOLD", "mult", target_mult)
		return target_mult
		
	elif elapsed_time < total_duration:
		var t := (elapsed_time - current_blend.fade_in - current_blend.hold) / current_blend.fade_out
		var eased_t := ease_in_out(t)
		var result := lerpf(target_mult, 1.0, eased_t)
		__log_("Phase: FADE_OUT", "t", t, "-> eased", eased_t, "-> mult", result)
		return result
		
	else:
		__log_("Phase: EXPIRED", "mult 1.0")
		return 1.0


static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


var LOG_B: bool = false

func __log_(...parts: Array):
	if LOG_B: print_.prefix("ValueInfluencer " + _influencer_name, pp.list_(parts))
