@abstract
class_name BasePHEState
extends EnemyStateUtils

var native_player: AnimationPlayer
var phe_feelings: PHEFeelings
var weapons: Array[PHWeapon]
var active_weapon: PHWeapon
var container: PHContainer
var combat: PHCombat

var state_name: String
var state_depth: int

# min time to stay in state. -1 means not applied (like for Top state or some idle state)
var commitment: float = 0.4
# max time to stay in state -1 means not applied (like for Top state or some idle state)
var fatigue: float = 20

## DANGER: do not use directly!
var __current_substate: BasePHEState = null

var is_composite: bool = false

## if action needs something special to work. Would be called from states container.
## Reason: We rarely can rely on _ready
func initialise() -> void:
	pass


func get_animator_manager() -> EnemyAnimatorManager:
	return animator_manager


func __warn_depth_violation(_next_substate_name: String) -> bool:
	if _next_substate_name == "":
		return false
	var _next_substate := container.get_state_by_name(_next_substate_name)
	if _next_substate.state_depth != state_depth + 1:
		__log_warn(true, "next substate is not a substate of the curr one!",
			pp.in_q(_next_substate), "its depth", _next_substate.state_depth)
		return true
	return false


func works_longer_than_fatigue() -> bool:
	if fatigue == -1:
		return false
	if works_longer_than(fatigue):
		return true
	return false

func works_less_than_commitment() -> bool:
	if commitment == -1:
		return false
	if works_less_than(commitment):
		return true
	return false


var __is_entered: bool = false

## internal
func _on_enter_state():
	if not is_composite:
		PREV_LEAF = me.update_current_leaf_state(self)
	
	mark_enter_action()

	me.update_state_history(state_name)

	if __is_entered:
		__log_warn(true, "Already entered")
	__is_entered = true

	
	if is_composite:
		var _next_state = ""
		var _reason = ""
		var initial_state_verdict = choose_initial_substate(_next_state, _reason)
		if not initial_state_verdict.needs_switch():
			__log_warn(true, "choose_initial_substate returned empty verdict!")
		__log_phe_decision("Initial choice |", initial_state_verdict.get_reason(), " |", __get_common_context(), " => ", initial_state_verdict.next_state)
		_switch_substate(initial_state_verdict.next_state)

	# after choose_initial_substate!
	on_enter_state()


## internal
func _on_exit_state():
	__log_ext("")
	if not __is_entered:
		__log_warn(true, "Calling exit while not entered")
	__is_entered = false

	if is_composite and get_current_substate() != null:
		get_current_substate()._on_exit_state()
		reset_current_substate()
	on_exit_state()


## to override
func on_exit_state():
	pass


## to override
func on_enter_state():
	pass


var __state_declined: String = "x"

## for the top state this is called from model
func _update(delta: float):
	accumulate_time_spent(delta)
	if works_longer_than_fatigue():
		me.fatigue_raised = true

	# do ur stuff
	update(delta)
	var _applied = e_movement.apply_gravity(delta)
	if _applied:
		__log_phe__upd("applied gravity ☄️")
		
	if is_composite:
		var verdict = _check_substate_transition(delta)
		if verdict.needs_switch():
			if __state_declined != verdict.next_state:
				__log_phe_decision(verdict.get_reason(), " |", __get_common_context(), " => ", verdict.next_state)
			# else:
				# __log_phe_decision("still want", verdict.next_state)
			var _current_sbs = get_current_substate()
			if _current_sbs != null and _current_sbs.works_less_than_commitment():
				# todo: consider adding new state to queue
				# print_.note(__state_declined, true)
				if __state_declined != verdict.next_state:
					__log_phe_decision(em.pin, "curr sbs worked < commit, switch declined ✖️",
						pp.in_q(_current_sbs.state_name), "Commit", _current_sbs.commitment, " |", _current_sbs.__log_timings())
				__state_declined = verdict.next_state
			else:
				__state_declined = "x"
				_switch_substate(verdict.next_state)
		
		# call ur children to do stuff
		get_current_substate()._update(delta)


## To override
func update(delta: float):
	pass


## any state can update the value returning from this function.
## example: attack state can signal that it ended using this.
## Using of this function is a decision of the parent state. It could ignore it.
func is_ended() -> bool:
	return false


func get_lowest_active_state() -> BasePHEState:
	if is_composite:
		return get_current_substate().get_lowest_active_state()
	return self


## COMPOSITOR ONLY LOGIC
# region: code


func get_current_substate() -> BasePHEState:
	__warn_not_composite()
	return __current_substate


func set_current_substate(next_state_name: String) -> void:
	__warn_not_composite()
	var _next_substate = container.get_state_by_name(next_state_name)
	__warn_depth_violation(_next_substate.state_name)
	__current_substate = _next_substate


func reset_current_substate() -> void:
	__warn_not_composite()
	__current_substate = null


## not to override: wrapper around check_substate_transition, makes important checks
func _check_substate_transition(delta) -> VerdictPH:
	var _next_state = ""
	var _reason = ""
	var current_substate_ = get_current_substate()
	if not current_substate_: # DANGER: should not happen! very crucial
		print_.warn("no current_substate_ in _check_substate_transition. returning empty verdict", true)
		return VerdictPH.new()
	var _sbs_verdict = check_substate_transition(delta, current_substate_, "", "")
	
	# NOTE: for now no difference between empty verdict and verdict with the same next state
	if _sbs_verdict.next_state == current_substate_.state_name:
		_sbs_verdict.reset_next_state()
	
	 # TODO: not just warning but using some fall back, probably choose_initial_substate
	__warn_depth_violation(_sbs_verdict.next_state)
	return _sbs_verdict


## usually overriden for composite states
## 'current_substate' - to work with to make a decisions. NOTE: guaranteed to be not null!
## '_next_state' - is empty string on function entry. State will fill it and set to verdict
## '_reason' - is empty string on function entry. State should fill it and add to verdict reason
## all this args could ve been initiated inside check_substate_transition, 
## but this way all function implementations are more uniformed and less verbose and prone to error
## NOTE: for simplicity, return of this function is always 'return VerdictPH.new(_next_state, _reason)'
## NOTE: won't be called for leaf states at all
func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	_reason = "default implementation"
	return VerdictPH.new(_next_state, _reason)


## '_next_state' - is empty string on function entry. State will fill it and set to verdict
## '_reason' - is empty string on function entry. State should fill it and add to verdict reason
## NOTE: for simplicity, return of this function is always 'return VerdictPH.new(_next_state, _reason)'
## NOTE: won't be called for leaf states at all
func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_reason = em.crucial_x2 + "state must implement choose_initial_substate!"
	return VerdictPH.new(_next_state, _reason)


func _switch_substate(next_state_name: String):
	if get_current_substate() == null:
		__log_phe("↪️", "-  x  -" + " -> " + next_state_name)
	else:
		__log_phe("↪️", get_current_substate().state_name + " -> " + next_state_name)

	if get_current_substate() != null:
		get_current_substate()._on_exit_state()

	set_current_substate(next_state_name)
	
	get_current_substate()._on_enter_state()
	
	if not get_current_substate().is_composite:
		set_substate_anim_to_play()


func set_substate_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0):
	get_current_substate().set_anim_to_play(override_blend_time, override_start_time_offset)

# endregion


## LEAF ONLY LOGIC
# region: code

var default_sp: DefaultSpeedConfig = DefaultSpeedConfig.new()
var blend_time = ActionData.BlendTime.new()
var start_time_offset = ActionData.StartTimeOffset.new()

## do not use this in states. Use blend_time and start_time_offset features
var _actual_blend_time: float
var _actual_start_time_offset: float

# see player's PREV_ACTION for a reference
var PREV_LEAF: String = ""


# ▶️
func set_anim_to_play(override_blend_time: float = -1.0, override_start_time_offset: float = -1.0) -> void:
	__warn_not_leaf("set_anim_to_play")
	_actual_blend_time = blend_time.calculate_actual(PREV_LEAF)
	if override_blend_time != -1.0:
		_actual_blend_time = override_blend_time
	var _direct_tr = direct_time_remaining()
	# if _direct_tr < _actual_blend_time:
		# __log_upd(em.pin, pp.compare("_direct_tr", _direct_tr, "<", "_calc-blend-t", _actual_blend_time), "-> will be d-t-r")
		# _actual_blend_time = _direct_tr
	_actual_start_time_offset = start_time_offset.calculate_actual(PREV_LEAF)
	if override_start_time_offset != -1.0:
		_actual_start_time_offset = override_start_time_offset
		
	__log_anim()
	get_animator_manager().set_anim_to_play(anim.anim_id, _actual_blend_time, _actual_start_time_offset)

# region: BACKEND ANIMATION GETTERS
# TODO: this is not working right now
func get_root_position_delta(delta: float) -> Vector3:
	__warn_not_leaf("get_root_position_delta")
	return Vector3.ZERO
	# return states_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta)

func halberd_hurts() -> bool:
	__warn_not_leaf("halberd_hurts")
	return false
	# return states_data_repo.get_halberd_hurts(backend_animation, get_progress())

func aura_hurts() -> bool:
	__warn_not_leaf("aura_hurts")
	return false
	# return states_data_repo.get_halberd_hurts(backend_animation, get_progress())
# endregion

func get_animation_length() -> float:
	__warn_not_leaf("get_animation_length")
	return anim.duration


# endregion


## Not like other interal functions that use "do your stuff then pass the call down the tree"
## Reactions are heavily defaulted (almost all states react on hit/parry in the same way)
##     => - here is a single default reaction 
##        - it is called once from the bottom leaf, the working state.
## Otherwise, there could be problems like: calling it on each node in the tree and get damaged X times
func _react_on_hit(hit: HitData):
	get_lowest_active_state().react_on_hit(hit)


func react_on_hit(hit: HitData):
	phe_feelings.lose_health(hit.damage)


## call this in update method in states that use weapons anyhow
func manage_weapons():
	pass
	# combat.update_is_attacking(states_data_repo.is_attacking(active_weapon.weapon_name, backend_animation, get_progress()))
	# for weapon in weapons:
		# weapon.is_attacking = states_data_repo.is_attacking(weapon.weapon_name, backend_animation, get_progress())

## this needs to be called on_exit_state of every state that touches weapons
## We need to to clear weapon ignore list andto deactivate weapons.
func deactivate_weapons():
	pass
	# for weapon in weapons:
		# weapon.hitbox_ignore_list.clear()
		# weapon.is_attacking = false


# region: __LOGS


func __get_common_context() -> String:
	var _msg = ""
	_msg += pp.s("Pl->E", pp.round_01(distance_to_player()),
		"∠" + pp.rad2deg(signed_angle_to_player(), true))
	return _msg

func __warn_not_composite(comment: String = ""):
	if not is_composite:
		__log_warn(true, comment + " soperation on substate of the leaf state", pp.in_q(state_name))

func __warn_not_leaf(comment: String = ""):
	if is_composite:
		__log_warn(true, comment + " operation with data which make sense only for leaf state!", pp.in_q(state_name))


func __log_state() -> String:
	var _r = ""
	if state_name == PHEState._TOP:
		_r += "☐"
	else:
		_r += "▨" if is_composite else "☘︎"
	_r += state_name
	_r += " "
	_r += pp.in_sq(str(state_depth))
	if is_composite:
		_r += "-> "
		var _curr_sbs = get_current_substate()
		if _curr_sbs:
			_r += _curr_sbs.state_name
		else:
			_r += "-x-"
	return _r

func __log_indent() -> int:
	var _m = {0: 0, 1: 1, 2: 3, 3: 5, 4: 8, 5: 10}
	return _m.get(state_depth, 18)

func __log_phe(...parts: Array):
	print_.phe_sm(__log_state(), pp.list_(parts), __log_indent())

func __log_phe_choose(chose_state_: String, ...parts: Array):
	print_.phe_check(__log_state(), "Chose " + chose_state_ + " " + pp.list_(parts), __log_indent())

func __log_phe_check(...parts: Array):
	print_.phe_check(__log_state(), pp.list_(parts), __log_indent())

func __log_phe_decision(...parts: Array):
	print_.phe_sm(__log_state() + em.verdict, pp.list_(parts), __log_indent())

func __log_ent(...parts: Array):
	print_.phe_sm(__log_state() + pp.on_ent, pp.list_(parts), __log_indent())


func __log_timings() -> String:
	var _actual_time_spent = get_actual_time_spent()
	var _time_msg = ""
	_time_msg += pp.round_01(_actual_time_spent) + "| "
	
	if is_composite:
		return _time_msg
	
	var _anim_time_spent = get_animator_manager().get_curr_anim_time_spent()
	var _anim_effective_dur = _effective_duration()
	var _anim_time_remainin = _effective_duration() - time_spent()
	var _anim_eff_time_spent = get_animator_manager().get_current_anim_effective_time_spent()
	var _anim_dur = get_animator_manager().get_curr_anim().duration
	var _anim_native_dur = get_animator_manager().get_curr_anim().native_anim.length
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

func __log_ext(...parts: Array):
	print_.phe_sm(pp.s(__log_state(), pp.on_ext, __log_timings()), pp.list_(parts), __log_indent())

func __log_phe__upd(...parts: Array):
	print_.phe_sm(__log_state() + pp.on_internal_upd, pp.list_(parts), __log_indent())

func __log_upd(...parts: Array):
	print_.phe_sm(__log_state() + pp.on_upd, pp.list_(parts), __log_indent())

func __log_warn(crucial: bool, ...parts: Array):
	print_.warn(pp.s(__log_state(), pp.list_(parts),
		"\n\t\t", me.__pp_state_history()),
		crucial)

func __log_anim():
	print_.phe_anim(state_name, anim.anim_name, _actual_blend_time, _actual_start_time_offset, anim.speed_scale, PREV_LEAF)

# endregion
