@abstract
class_name PlActionTimeManagement
extends TimeManagement


# TODO: merge with AnimTimeManagement
#       this also means validating that PlayerAnimatorManager aligns with BaseAnimatorManager

var animator_manager: PlAnimatorManager
var anim_container: BaseAnimationContainer

## not nulllable
var anim: AnimationData


func _effective_duration() -> float:
	return animator_manager.get_curr_anim_effective_duration()


## Use this for comparison with absolute data (native anim timings). 
## Usually it's a work with the markers.
## Accounts for all speed scales 
## May start with start offset
func effective_time_spent() -> float: # ✔️
	if not animator_manager.get_curr_anim().is_looping:
		return animator_manager.get_curr_anim_effective_time_spent()
	else:
		return get_actual_time_spent()


## Use this for working with relative data (animator's timeline).
## Example: working with blend times.
## starts with 0.
## Accounts for all speed scales 
func time_spent() -> float: # ✔️
	if not animator_manager.get_curr_anim().is_looping:
		return animator_manager.get_curr_anim_time_spent()
	else:
		return get_actual_time_spent()


## NOTE: in case of looping animations returns big number
func time_remaining() -> float: # ✔️
	var _curr_anim := animator_manager.get_curr_anim()
	if not _curr_anim:
		print_.note(false, "direct_time_remaining - not _curr_anim, return 0.0")
		return 0.0
	if _curr_anim.is_looping:
		return Constants.BIG_MEANINGLESS_NUMBER
	return _effective_duration() - time_spent() # or: duration - eff time spent


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
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		__log_warn("passed_marker - no time - will return false")
		return __reject()

	if effective_time_spent() >= marker_time + add_time:
		return true
	return false


func before_marker(marker_name: String) -> bool:
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		__log_warn("before_marker - no time - will return false", )
		return __reject()

	if effective_time_spent() < marker_time:
		return true
	return false


func __reject() -> bool:
	__log_warn("TM rejected -1!")
	return false


func pp_name() -> String:
	return "PlActionTimeManagement"

func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	error_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_WARNING, pp.list_(context))
