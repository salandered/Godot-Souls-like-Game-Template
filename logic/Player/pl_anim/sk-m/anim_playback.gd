extends RefCounted
class_name AnimPlayback

var anim: AnimationData
var native_anim: Animation # shortcut for anim.native_anim
var time_spent: float ## in sc
## Will start animation from a specific timestamp. Note that it adds up with animation's .start_time
var start_offset: float ## in sc


func _init(_anim: AnimationData, _time_spent: float, _offset: float):
	anim = _anim
	native_anim = _anim.native_anim
	time_spent = _time_spent
	start_offset = _offset


## returns a time, at which we really are inside a native_anim
## this is a link between time_spent (animator's timeline) and real keyframe data. 
func get_effective_progress() -> float:
	var time = time_spent + anim.start_time + start_offset
	if anim.is_looping:
		return fmod(time, anim.duration)
	return time


func _to_string() -> String:
	var time_spent_pct = (time_spent / anim.duration) * 100 if anim.duration > 0 else .0
	var msg = "AnimPlay: %24s %5.1f (%5.2f/%5.2f) off:%5.2f ef-pr %5.2f" % [
		pp.in_q(anim.anim_name),
		time_spent_pct,
		time_spent,
		anim.duration,
		start_offset,
		get_effective_progress()
	]

	msg += '\n\t\t\t' + anim.to_string_compact()
	return msg