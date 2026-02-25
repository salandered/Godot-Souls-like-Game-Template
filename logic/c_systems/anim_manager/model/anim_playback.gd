extends RefCounted
class_name AnimPlayback

var anim: AnimationData
var time_spent: float ## in sc, scaled
## Will start animation from a specific timestamp
var start_offset: float ## in sc

## DOCS: Examples of all the timelines
# region: 
## case 1 (non loop)
## native anim: 0 - 1.5. length 1.5. duration 1.5
## time_spent: 0 - 1.5 (if switched in time)
## effective_progress: 0 - 1.5
## real time spent: 0 - 1.5
##
## case 2 (non loop)
## native anim: 0 - 1.5. length 1.5. duration 1.5
## start_offset: 0.2
## time_spent:  0 - 1.3 (if switched in time)
## effective_progress: 0.2 - 1.5
## real time spent: 0 - 1.3
##
## case 3 (non loop)
## native anim: 0 - 1.5. length 1.5. duration 1.5
## anim.speed_scale (or global speed scale): 1.5
## time_spent: still 0 - 1.5. (it d be going faster)
## effective_progress: 0 - 1.5
## real time spent: 0 - 1.0
# endregion

func _init(_anim: AnimationData, _time_spent: float, _offset: float):
	anim = _anim
	time_spent = _time_spent
	start_offset = _offset


## returns a time, at which we really are inside a native_anim
## this is a link between time_spent (animator's timeline) and real keyframe data. 
## (while both accounts for a speed scales)
func get_effective_time_spent() -> float:
	var time := time_spent + start_offset
	if anim.is_looping:
		return fmod(time, anim.duration)
	return time


func get_effective_duration() -> float:
	if anim.is_looping:
		return anim.duration
	else:
		return anim.duration - start_offset


func _to_string() -> String:
	var msg := "AnimPlay: %20s Prog/EffDur: %5.2f / %5.2f  TimeSpent/dur: %5.2f / %5.2f  offset %5.2f" % [
		pp.in_q(anim.anim_name),
		get_effective_time_spent(),
		get_effective_duration(),
		time_spent,
		anim.duration,
		start_offset,
	]
	msg += '\n\t\t\t' + anim.to_string_compact()
	return msg


func _to_string_short() -> String:
	var msg := "Prog %5.2f  %5.2f / %5.2f  off %5.2f  %20s " % [
		get_effective_time_spent(),
		time_spent,
		anim.duration,
		start_offset,
		pp.in_q(anim.anim_name),
	]
	return msg
