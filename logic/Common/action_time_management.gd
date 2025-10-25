extends TimeManagement
## can be inherited by any action/state which is tied to animation 1 to 1 and uses animator_manager
## firstly was used for player actions => terminology uses 'action'
## extends TimeManagement so has animation agnostic TM packed
class_name ActionTimeManagement

var animator_manager: BaseAnimatorManager
var anim_container: BaseAnimationContainer

var anim: AnimationData


func __we_have_anim() -> bool:
	return anim != null

func _effective_duration() -> float:
	if anim:
		return animator_manager.get_curr_anim_effective_duration()
	else:
		print_.warn("_effective_duration is called on node without anim assigned. return 1.0")
		return 1.0


## Use this for comparison with absolute data (native anim timings). 
## Usually it's a work with the markers.
## Accounts for all speed scales 
## May start with start offsets
func effective_time_spent() -> float: # ✔️
	if __we_have_anim() and not animator_manager.get_curr_anim().is_looping:
		return animator_manager.get_current_anim_effective_time_spent()
	else:
		return get_actual_time_spent()


## Use this for working with relative data (animator's timeline).
## Example: working with blend times.
## Time_spent starts with 0.
## Accounts for all speed scales 
## TODO: calculate the right value for looping animations in manager
func time_spent() -> float: # ✔️
	if __we_have_anim() and not animator_manager.get_curr_anim().is_looping:
		return animator_manager.get_curr_anim_time_spent()
	else:
		return get_actual_time_spent()


## NOTE: in case of looping animations returns big number
func time_remaining() -> float: # ✔️
	if __we_have_anim():
		var _curr_anim = animator_manager.get_curr_anim()
		if not _curr_anim:
			print_.note("direct_time_remaining - not _curr_anim, return 0.0")
			return 0.0
		if _curr_anim.is_looping:
			return Constants.BIG_MEANINGLESS_NUMBER
		return _effective_duration() - time_spent() # or: duration - eff time spent
	else:
		print_.warn("time_remaining is called on node without anim assigned. return 0.0")
		return 0.0


## TODO: current usage of ActionTimeManagement and BaseAnimatorManager works poorly on edge cases
##      e.g. if curr action checks time_remaining() before calling manager.set_anim_to_play,
##           then result will be for the prev action! 
##		If u know what u doing, it's more reliable to call this method
## NOTE: in case of looping animations returns big number
func direct_time_remaining() -> float:
	var _curr_anim = animator_manager.get_curr_anim()
	if not _curr_anim:
		print_.note("direct_time_remaining - not _curr_anim, return 0.0")
		return 0.0
	if _curr_anim.is_looping:
		return Constants.BIG_MEANINGLESS_NUMBER
	var _r = animator_manager.get_curr_anim_effective_duration() - animator_manager.get_curr_anim_time_spent()
	return _r


func works_longer_than(time: float) -> bool:
	if time == -1: return __reject()
	if time_spent() >= time:
		return true
	return false


func works_less_than(time: float) -> bool:
	if time == -1: return __reject()
	if time_spent() < time:
		return true
	return false


func works_between(start: float, finish: float) -> bool:
	if start == -1 or finish == -1: return __reject()
	if time_spent() >= start and time_spent() <= finish:
		return true
	return false


func passed_marker(marker_name: String, add_time: float = 0.0) -> bool:
	if not anim:
		print_.warn("passed_marker is called on node without anim assigned. return false")
		return false
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		print_.warn("passed_marker - no time - will return false", true)
		return __reject()

	if effective_time_spent() >= marker_time + add_time:
		return true
	return false


func before_marker(marker_name: String) -> bool:
	if not anim:
		print_.warn("before_marker is called on node without anim assigned. return false")
		return false
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		print_.warn("before_marker - no time - will return false", true)
		return __reject()

	if effective_time_spent() < marker_time:
		return true
	return false


func __reject() -> bool:
	print_.warn("TM rejected -1!")
	return false
