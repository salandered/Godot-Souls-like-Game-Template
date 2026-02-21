extends BasePHEState
class_name BasePHELeaf


var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()
var blend_time := ActionData.BlendTime.new(0.3)
var start_time_offset := ActionData.StartTimeOffset.new(0.0)

var y_offset_adjustment: float

# see player's PREV_ACTION for a reference
var PREV_LEAF: StringName = ""

## non null
var anim: AnimationData

var TIME_REMAINING_TO_END := 0.15

var __is_entered: bool = false

var APPLY_GRAVITY: bool = true

func validate_substate_depth(parent_depth: int) -> bool:
	return true


## Priority:
##   - special marker
##   - specific const that state can set
##   - default value
## NOTE: for looping anim time_remaining returns big number, so it would be false
##		 but still we allow having ALLOWS_SWITCH just in case to hard stop loop
func is_ended() -> bool:
	if anim.does_marker_exist(MarkerName.ALLOWS_SWITCH) \
		and passed_marker(MarkerName.ALLOWS_SWITCH):
			return true
	elif time_remaining() < TIME_REMAINING_TO_END:
		return true
	else: # may be check commitment as a fallback
		return false


## internal
func _on_enter_state() -> void:
	mark_enter_state()
	PREV_LEAF = me.update_curr_leaf_state(self )

	if me.record_state_history:
		me.update_state_history(state_name)


	if __is_entered:
		__log_error("Already entered")
	__is_entered = true

	on_enter_state()
	
	animate() # NOTE: after entering

	
## internal
func _on_exit_state() -> void:
	if __ELA(): __log_ext("")
	if not __is_entered:
		__log_error("Calling exit while not entered")
	__is_entered = false

	on_exit_state()


func call_accumulate_time_spent(delta: float) -> void:
	accumulate_time_spent(delta)


func _update(delta: float) -> void:
	call_accumulate_time_spent(delta)

	if works_longer_than_fatigue():
		me.fatigue_raised = true

	update(delta)

	if APPLY_GRAVITY:
		if me.get_area_awareness().is_on_floor():
			pass
		elif me.get_area_awareness().is_almost_on_floor():
			var _applied := e_movement.apply_gravity(delta, 3.0)
			# if _applied:
				# __log_phe__upd("applied gravity ☄️")


func works_longer_than_fatigue() -> bool:
	return CommitCheck.works_longer_than_fatigue_leaf(self )

func works_less_than_commitment() -> bool:
	return CommitCheck.works_less_than_commitment_leaf(self )


## REACTIONS TO EXTERNAL EVENTS
# region

## DOCS
## WARNING simple code here
## i dont know how it will play out
## Leafs can override react_on_hit to mute, or set constants to override calculate_reaction result


func react_on_hit(hit: HitData):
	if __ELA(): __log_phe("react_on_hit, will lose health", pp.in_q(hit))
	
	phe_feelings.lose_health(hit.damage)

	var _sig_data := me.get_sig_container().get_by_sig_id(SignalID.sfx_react_on_hit)
	SigUtils.safe_emit_sig_data(_sig_data, {}, false)

	var react_cfg := ReactionOnHit.calculate_reaction_for_enemy(hit, state_name)
	if not react_cfg:
		if __ELA(): __log_upd("state mutes react_on_hit, ignoring")
		return
	else:
		if __ELA(): __log_upd("Calculated react_cfg", react_cfg)
	
	var actual_overlay_weight := react_cfg.overlay_weight
	var actual_bone_mask := react_cfg.bone_mask


	var overlay_config := OverlayConfig.new(
		OverlayConfig.Weight.new(actual_overlay_weight, actual_overlay_weight / 2),
		BlendConfig.new(),
		1.0,
		actual_bone_mask)

	set_overlay_anim_to_play(react_cfg.anim_id, overlay_config)


func is_apply_gravity() -> bool:
	return APPLY_GRAVITY

# endregion


func get_current_substate_by_depth(depth: int) -> BasePHEState:
	if state_depth == depth:
		return self
	return null


##

## default implementation. Called automatically.
## Example use cases to override: mute playing animation or overriden values for set_anim_to_play
## NOTE: called AFTER the on_enter_state()
func animate() -> void: # ▶️
	set_anim_to_play()


func set_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0) -> void:
	var _actual_blend_time := blend_time.calculate_actual(PREV_LEAF)
	if override_blend_time != -1.0:
		_actual_blend_time = override_blend_time
	var _actual_start_time_offset := start_time_offset.calculate_actual(PREV_LEAF)
	if override_start_time_offset != -1.0:
		_actual_start_time_offset = override_start_time_offset
		
	if __ELA(): __log_anim(_actual_blend_time, _actual_start_time_offset)
	get_animator_manager().set_anim_to_play(anim.anim_id, _actual_blend_time, _actual_start_time_offset)


func set_overlay_anim_to_play(overlay_anim_id: StringName, overlay_config: OverlayConfig) -> void:
	if __ELA(): __log_overlay_anim(overlay_anim_id, overlay_config)
	get_animator_manager().set_overlay_anim(overlay_anim_id, overlay_config)


## ANIM BASED TIME MANAGEMENT
# region

func effective_time_spent() -> float:
	return ActionTimeManagement.effective_time_spent(get_animator_manager(), self )


func effective_time_spent_unscaled() -> float:
	return ActionTimeManagement.effective_time_spent_unscaled(get_animator_manager(), self )


func effective_duration() -> float:
	return ActionTimeManagement._effective_duration(get_animator_manager())


func time_spent() -> float:
	return ActionTimeManagement.time_spent(get_animator_manager(), self )


func time_remaining() -> float:
	return ActionTimeManagement.time_remaining(get_animator_manager(), self )


func direct_time_remaining() -> float:
	return ActionTimeManagement.direct_time_remaining(get_animator_manager())


func works_longer_than(time: float) -> bool:
	return ActionTimeManagement.works_longer_than(time, get_animator_manager(), self )


func works_less_than(time: float) -> bool:
	return ActionTimeManagement.works_less_than(time, get_animator_manager(), self )


func works_between(start: float, finish: float) -> bool:
	return ActionTimeManagement.works_between(start, finish, get_animator_manager(), self )


func passed_marker(marker_name: StringName, add_time: float = 0.0) -> bool:
	return ActionTimeManagement.passed_marker(marker_name, get_animator_manager(), anim, self , add_time)


func before_marker(marker_name: StringName) -> bool:
	return ActionTimeManagement.before_marker(marker_name, get_animator_manager(), anim, self )

# endregion


# region: GET ANIMATION PARAMETERS

# func is_invincible() -> bool:
# 	return anim_params_container.is_invincible(anim.native_anim, effective_time_spent_unscaled())
	

func is_weapon_hurts(weapon_id: StringName, __log: bool = false) -> bool:
	var _r: bool = false
	_r = anim_params_container.is_weapon_hurts(weapon_id, anim.native_anim, effective_time_spent_unscaled())

	if _r and __log:
		print_.prefix("// HURT")
	return _r


# endregion


## SPECIFIC LOGIC
# region


func sync_with_curr_loco_anim(next_anim: AnimationData, next_anim_correction: float = 0.0) -> float:
	var curr_anim_progress: float = get_animator_manager().get_curr_anim_effective_time_spent()
	var result_offset := AnimHelpers.sync_with_loco_anim(anim, curr_anim_progress, next_anim, next_anim_correction)
	return result_offset

# endregion


# region: __LOGS

func __log_indent() -> int:
	return 6

func __log_state() -> String:
	var _r := ""
	_r += "☘︎"
	_r += state_name
	_r += " "
	# _r += pp.in_sq(str(state_depth))
	return _r

func __log_timings() -> String:
	var _actual_time_spent := get_actual_time_spent()
	var _time_msg := ""
	_time_msg += pp.round_01(_actual_time_spent) + "| "
	
	var _anim_time_spent := get_animator_manager().get_curr_anim_time_spent()
	var _anim_effective_dur := effective_duration()
	var _anim_time_remainin := time_remaining()
	var _anim_eff_time_spent := get_animator_manager().get_curr_anim_effective_time_spent()
	var _anim_dur := get_animator_manager().get_curr_anim().duration
	var _anim_native_dur := get_animator_manager().get_curr_anim().native_anim.length
	_time_msg += "ts/Ed/tr %.1f/%.1f/%.1f | Ets %.1f" % [
		_anim_time_spent,
		_anim_effective_dur,
		_anim_time_remainin,
		_anim_eff_time_spent,
	]
	if _anim_effective_dur != _anim_native_dur or _anim_effective_dur != _anim_dur:
		_time_msg += " | Ad-Nd %.1f-%.1f" % [
			_anim_dur,
			_anim_native_dur
		]

	return _time_msg

func __log_anim(_actual_blend_time: float, _actual_start_time_offset: float):
	if __LOG_ANIM: print_.phe_anim(state_name, anim.anim_name, _actual_blend_time, _actual_start_time_offset, anim.speed_scale, PREV_LEAF)

func __log_overlay_anim(overlay_anim_id: StringName, overlay_config: OverlayConfig):
	if __LOG_OVERLAY_ANIM: print_.phe_overlay_anim(state_name, overlay_anim_id, overlay_config)


# endregion
