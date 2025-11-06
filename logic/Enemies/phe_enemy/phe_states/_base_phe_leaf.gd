extends BasePHEState
class_name BasePHELeaf


var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()
var blend_time := ActionData.BlendTime.new(0.3)
var start_time_offset := ActionData.StartTimeOffset.new()

var y_offset_adjustment: float

# see player's PREV_ACTION for a reference
var PREV_LEAF: String = ""

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
	if anim.does_marker_exist(Marker.Name_.ALLOWS_SWITCH) \
		and passed_marker(Marker.Name_.ALLOWS_SWITCH):
			return true
	elif time_remaining() < TIME_REMAINING_TO_END:
		return true
	else: # may be check commitment as a fallback
		return false


## internal
func _on_enter_state() -> void:
	mark_enter_state()
	PREV_LEAF = me.update_curr_leaf_state(self)
	me.update_state_history(state_name)


	if __is_entered:
		__log_warn(true, "Already entered")
	__is_entered = true

	on_enter_state()
	
	animate() # NOTE: after entering

	
## internal
func _on_exit_state() -> void:
	__log_ext("")
	if not __is_entered:
		__log_warn(true, "Calling exit while not entered")
	__is_entered = false

	on_exit_state()


func _update(delta: float) -> void:
	accumulate_time_spent(delta)

	if works_longer_than_fatigue():
		me.fatigue_raised = true

	update(delta)

	if APPLY_GRAVITY:
		var _applied := e_movement.apply_gravity(delta)
		# if _applied:
			# __log_phe__upd("applied gravity ☄️")
		

func works_longer_than_fatigue() -> bool:
	return CommitCheck.works_longer_than_fatigue_leaf(self)

func works_less_than_commitment() -> bool:
	return CommitCheck.works_less_than_commitment_leaf(self)


## REACTIONS TO EXTERNAL EVENTS
# region

## DOCS
## WARNING most simple raw code here for now
## i dont know how it will play out
## Leafs can override react_on_hit to mute, or override pickers _pick

## can be overriden
func react_on_hit(hit: HitData):
	__log_phe("react_on_hit, will lose health", pp.in_q(hit))
	# animator_manager.set_overlay_anim()
	phe_feelings.lose_health(hit.damage)
	
	var anim_id_ = _pick_react_anim(hit)
	
	var overlay_weight: float
	if hit.damage < 1.0:
		overlay_weight = 0.0
	else:
		overlay_weight = _pick_overlay_weight(hit)
	
	var bone_mask = _pick_bone_mask(hit)
	
	var overlay_config = OverlayConfig.new(
		OverlayConfig.Weight.new(overlay_weight, overlay_weight / 2),
		OverlayConfig.Blend.new(),
		1.0,
		bone_mask)
	
	set_overlay_anim_to_play(anim_id_, overlay_config)


func _pick_react_anim(hit: HitData) -> String:
	var _r: String = PHEA.react.react_from_R
	if hit.anim_id == A.attack.attack_from_run:
		_r = PHEA.react.react_gut
	elif hit.damage > 10:
		_r = PHEA.react.react_gut
	else:
		_r = ra.spick_random(PHEA.react.react_from_R, PHEA.react.react_from_L)
	return _r


func _pick_overlay_weight(hit: HitData) -> float:
	var mapped_value = hit.damage / 15.0 ## very approximately
	return clampf(mapped_value, 0.0, 1.0)


func _pick_bone_mask(hit: HitData) -> Array[int]:
	return BoneMask.get_upper_body()


# endregion


## default implementation. Called automatically.
## Example use cases to override: mute playing animation or overriden values for set_anim_to_play
## NOTE: called AFTER the on_enter_state()
func animate() -> void: # ▶️
	set_anim_to_play()


func set_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0) -> void:
	var _actual_blend_time = blend_time.calculate_actual(PREV_LEAF)
	if override_blend_time != -1.0:
		_actual_blend_time = override_blend_time
	var _actual_start_time_offset = start_time_offset.calculate_actual(PREV_LEAF)
	if override_start_time_offset != -1.0:
		_actual_start_time_offset = override_start_time_offset
		
	__log_anim(_actual_blend_time, _actual_start_time_offset)
	get_animator_manager().set_anim_to_play(anim.anim_id, _actual_blend_time, _actual_start_time_offset)


func set_overlay_anim_to_play(overlay_anim_id: String, overlay_config: OverlayConfig) -> void:
	__log_overlay_anim(overlay_anim_id, overlay_config)
	get_animator_manager().set_overlay_anim(overlay_anim_id, overlay_config)


## ANIM BASED TIME MANAGEMENT
# region

func effective_time_spent() -> float:
	return ActionTimeManagement.effective_time_spent(get_animator_manager(), self)


func effective_duration() -> float:
	return ActionTimeManagement._effective_duration(get_animator_manager())


func time_spent() -> float:
	return ActionTimeManagement.time_spent(get_animator_manager(), self)


func time_remaining() -> float:
	return ActionTimeManagement.time_remaining(get_animator_manager(), self)


func direct_time_remaining() -> float:
	return ActionTimeManagement.direct_time_remaining(get_animator_manager())


func works_longer_than(time: float) -> bool:
	return ActionTimeManagement.works_longer_than(time, get_animator_manager(), self)


func works_less_than(time: float) -> bool:
	return ActionTimeManagement.works_less_than(time, get_animator_manager(), self)


func works_between(start: float, finish: float) -> bool:
	return ActionTimeManagement.works_between(start, finish, get_animator_manager(), self)


func passed_marker(marker_name: String, add_time: float = 0.0) -> bool:
	return ActionTimeManagement.passed_marker(marker_name, get_animator_manager(), anim, self, add_time)


func before_marker(marker_name: String) -> bool:
	return ActionTimeManagement.before_marker(marker_name, get_animator_manager(), anim, self)

# endregion


# region: GET ANIMATION PARAMETERS

func is_vulnerable() -> bool:
	return anim_params_container.is_vulnerable(anim.native_anim, effective_time_spent())

func is_weapon_hurts(weapon_name: String, __log: bool = false) -> bool:
	var _r: bool = false
	match weapon_name:
		WeaponNames.big_pinga_blade:
			_r = anim_params_container.is_weapon_hurts(anim.native_anim, effective_time_spent())
		WeaponNames.bg_aura_weapon:
			_r = anim_params_container.is_aura_hurts(anim.native_anim, effective_time_spent())
		_:
			__log_warn_v2(false, "unknown weapon name " + pp.in_q(weapon_name), "is_weapon_hurts", "return false")
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

func __log_anim(_actual_blend_time, _actual_start_time_offset):
	if __LOG_ANIM: print_.phe_anim(state_name, anim.anim_name, _actual_blend_time, _actual_start_time_offset, anim.speed_scale, PREV_LEAF)

func __log_overlay_anim(overlay_anim_id: String, overlay_config):
	if __LOG_OVERLAY_ANIM: print_.phe_overlay_anim(state_name, overlay_anim_id, overlay_config)

# endregion