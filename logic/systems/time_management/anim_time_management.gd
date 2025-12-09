extends RefCounted
class_name ActionTimeManagement


static func _effective_duration(animator_manager: BaseAnimatorManager) -> float:
	return animator_manager.get_curr_anim_effective_duration()


## Accounts for all speed scales 
## May start with start offsets
static func effective_time_spent(animator_manager: BaseAnimatorManager, self_) -> float: # ✔️
	if not animator_manager.get_curr_anim().is_looping:
		return animator_manager.get_curr_anim_effective_time_spent()
	else: ## TODO: calculate the right value for looping animations in manager
		return self_.get_actual_time_spent()


## Use this for working with relative data (animator's timeline).
## Example: working with blend times.
## Time_spent starts with 0.
## Accounts for all speed scales 
static func time_spent(animator_manager: BaseAnimatorManager, self_) -> float: # ✔️
	if not animator_manager.get_curr_anim().is_looping:
		return animator_manager.get_curr_anim_time_spent()
	else: ## TODO: calculate the right value for looping animations in manager
		return self_.get_actual_time_spent()


## Use this for comparison with absolute data (native anim timings). 
## Usually it's a work with the markers.
static func effective_time_spent_unscaled(animator_manager: BaseAnimatorManager, self_) -> float:
	return animator_manager.get_curr_anim_position_unscaled()


## NOTE: in case of looping animations returns big number
static func time_remaining(animator_manager: BaseAnimatorManager, self_) -> float: # ✔️
	var _curr_anim := animator_manager.get_curr_anim()
	if not _curr_anim:
		print_.note(false, "not _curr_anim, return 0.0")
		return 0.0
	if _curr_anim.is_looping:
		return Constants.BIG_MEANINGLESS_NUMBER
	__log_dev(_curr_anim, animator_manager, self_)

	return _effective_duration(animator_manager) - time_spent(animator_manager, self_) # or: duration - eff time spent


## If u know what u doing, it may be more reliable to call this method
## NOTE: in case of looping animations returns big number
static func direct_time_remaining(animator_manager: BaseAnimatorManager) -> float:
	var _curr_anim := animator_manager.get_curr_anim()
	if not _curr_anim:
		print_.note(true, "direct_time_remaining - not _curr_anim, return 0.0")
		return 0.0
	if _curr_anim.is_looping:
		return Constants.BIG_MEANINGLESS_NUMBER
	var _r := animator_manager.get_curr_anim_effective_duration() - animator_manager.get_curr_anim_time_spent()
	return _r


static func works_longer_than(time: float, animator_manager: BaseAnimatorManager, self_) -> bool:
	if time == -1: return __reject()
	if time_spent(animator_manager, self_) >= time:
		return true
	return false


static func works_less_than(time: float, animator_manager: BaseAnimatorManager, self_) -> bool:
	if time == -1: return __reject()
	if time_spent(animator_manager, self_) < time:
		return true
	return false


static func works_between(start: float, finish: float, animator_manager: BaseAnimatorManager, self_) -> bool:
	if start == -1 or finish == -1: return __reject()
	if time_spent(animator_manager, self_) >= start \
		and time_spent(animator_manager, self_) <= finish:
		return true
	return false


static func passed_marker(marker_name: String, animator_manager: BaseAnimatorManager, anim: AnimationData, self_, add_time: float = 0.0) -> bool:
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		__log_warn("passed_marker - no time - will return false")
		return __reject()
	if effective_time_spent_unscaled(animator_manager, self_) >= marker_time + add_time:
	# if effective_time_spent(animator_manager, self_) >= marker_time + add_time:
		return true
	return false


static func before_marker(marker_name: String, animator_manager: BaseAnimatorManager, anim: AnimationData, self_) -> bool:
	var marker_time := anim.get_marker_time_by_name(marker_name)
	if marker_time == -1:
		__log_warn("before_marker - no time - will return false")
		return __reject()

	if effective_time_spent_unscaled(animator_manager, self_) < marker_time:
		return true
	return false


static func __reject() -> bool:
	__log_warn("TM rejected -1!")
	return false


static func __log_dev(_curr_anim, animator_manager, self_):
	pass
	# if _curr_anim.anim_id in [PHEA.attack.club_part_1, PHEA.attack.club_part_2]:
	# 	print_.dev("time_remaining eff dur - ts = result",
	# 	pp.s(_effective_duration(animator_manager),
	# 		time_spent(animator_manager, self_),
	# 		_effective_duration(animator_manager) - time_spent(animator_manager, self_)))


static func pp_name() -> String:
	return "ActionTimeManagement"

static func __log_warn(what: String, where: String = "", fallback: String = "", ...context: Array):
	print_.warn(what, pp.s(pp_name(), "|", where), fallback, WarnLevel.PUSH_WARNING, pp.list_(context))
