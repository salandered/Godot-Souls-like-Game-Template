@abstract
class_name BaseMechFighterState
extends BaseCharacterState


var me: MechFighter


var blend_time := ActionData.BlendTime.new(0.3)
var start_time_offset := ActionData.StartTimeOffset.new(0.0)

## non null
var anim: AnimationData


var PREV_STATE: String = ""


var TIME_REMAINING_TO_END := 0.0


## if state needs something special to work. Would be called from states container.
func _initialise() -> void:
	initialise()


func initialise() -> void:
	pass


## Priority:
##   - special marker
##   - specific const that state can set
##   - default value
## NOTE: for looping anim time_remaining returns big number, so it would be false
##		 use marker to stop the loop
func is_ended() -> bool:
	if anim.does_marker_exist(MarkerName.ALLOWS_SWITCH) \
		and passed_marker(MarkerName.ALLOWS_SWITCH):
			return true
	elif time_remaining() <= TIME_REMAINING_TO_END:
		return true
	else:
		return false


## internal
func _on_enter_state() -> void:
	mark_enter_state()
	
	PREV_STATE = me.get_prev_state_name()
	on_enter_state()
	
	animate() # NOTE: after entering


func on_enter_state() -> void:
	pass

func on_exit_state() -> void:
	pass


## internal
func _on_exit_state() -> void:
	on_exit_state()


func call_accumulate_time_spent(delta: float) -> void:
	accumulate_time_spent(delta)


func _update(delta: float) -> void:
	call_accumulate_time_spent(delta)
	update(delta)


## to override
func update(delta: float) -> void:
	pass


##


func react_on_hit(hit: HitData):
	pass

# endregion


func animate() -> void: # ▶️
	set_anim_to_play()


func set_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0) -> void:
	var _actual_blend_time := blend_time.calculate_actual(PREV_STATE)
	if override_blend_time != -1.0:
		_actual_blend_time = override_blend_time
	var _actual_start_time_offset := start_time_offset.calculate_actual(PREV_STATE)
	if override_start_time_offset != -1.0:
		_actual_start_time_offset = override_start_time_offset
		
	__log_anim(_actual_blend_time, _actual_start_time_offset)
	me.get_animator_manager().set_anim_to_play(anim.anim_id, _actual_blend_time, _actual_start_time_offset)


##


# endregion


## ANIM BASED TIME MANAGEMENT
# region

func effective_time_spent() -> float:
	return ActionTimeManagement.effective_time_spent(me.get_animator_manager(), self)


func effective_time_spent_unscaled() -> float:
	return ActionTimeManagement.effective_time_spent_unscaled(me.get_animator_manager(), self)


func effective_duration() -> float:
	return ActionTimeManagement._effective_duration(me.get_animator_manager())


func time_spent() -> float:
	return ActionTimeManagement.time_spent(me.get_animator_manager(), self)


func time_remaining() -> float:
	return ActionTimeManagement.time_remaining(me.get_animator_manager(), self)


func direct_time_remaining() -> float:
	return ActionTimeManagement.direct_time_remaining(me.get_animator_manager())


func works_longer_than(time: float) -> bool:
	return ActionTimeManagement.works_longer_than(time, me.get_animator_manager(), self)


func works_less_than(time: float) -> bool:
	return ActionTimeManagement.works_less_than(time, me.get_animator_manager(), self)


func works_between(start: float, finish: float) -> bool:
	return ActionTimeManagement.works_between(start, finish, me.get_animator_manager(), self)


func passed_marker(marker_name: String, add_time: float = 0.0) -> bool:
	return ActionTimeManagement.passed_marker(marker_name, me.get_animator_manager(), anim, self, add_time)


func before_marker(marker_name: String) -> bool:
	return ActionTimeManagement.before_marker(marker_name, me.get_animator_manager(), anim, self)

# endregion


# region: GET ANIMATION PARAMETERS


func is_weapon_hurts(weapon_name: String, __log: bool = false) -> bool:
	var _r: bool = false
	_r = me.get_anim_params_container().is_weapon_hurts(weapon_name, anim.native_anim, effective_time_spent_unscaled())

	if _r and __log:
		__log_("// HURT")
	return _r


##

func __ELA():
	return true


func __log_anim(_actual_blend_time: float, _actual_start_time_offset: float):
	print_.any_action_anim(state_name, anim.anim_name, _actual_blend_time, _actual_start_time_offset, PREV_STATE)
