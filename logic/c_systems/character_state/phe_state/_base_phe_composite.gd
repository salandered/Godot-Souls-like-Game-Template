@abstract
class_name BasePHEComposite
extends BasePHEState


## DANGER: do not use directly!
var __current_substate: BasePHEState = null


var __is_entered: bool = false

# todo: add validation that composite sbs are the same as in node tree
var supported_substates: SupportedSubstates


func validate_substate_depth(parent_depth: int) -> bool:
	return state_depth - parent_depth == 1


func _initialise() -> void:
	initialise()

	# after usual initialise
	supported_substates = SupportedSubstates.new(
		get_supported_substates(),
		state_name
	)
	

func initialise() -> void:
	pass


func is_ended() -> bool:
	if commitment == -1.0:
		return false
	else:
		return works_longer_than(commitment)


@abstract func get_supported_substates() -> Array[String]


func _on_enter_state() -> void:
	mark_enter_state()

	if me.record_state_history:
		me.update_state_history(state_name)

	if __is_entered:
		__log_error("Already entered")
	__is_entered = true

	
	var _next_state := ""
	var _reason := ""
	var initial_state_verdict := _choose_initial_substate(_next_state, _reason)

	if __ELA(): __log_phe_decision("Initial choice |", initial_state_verdict.get_reason(), " |", __get_common_context(), " => ", initial_state_verdict.next_state)
	_switch_substate(initial_state_verdict.next_state)

	# after choose_initial_substate! or not.. But order is important
	on_enter_state()


## internal
func _on_exit_state() -> void:
	if __ELA(): __log_ext("")
	if not __is_entered:
		__log_error("Calling exit while not entered")
	__is_entered = false

	if get_current_substate() != null:
		get_current_substate()._on_exit_state()
		reset_current_substate()
	on_exit_state()


func call_accumulate_time_spent(delta: float) -> void:
	accumulate_time_spent(delta)

var __state_declined: String = "x"
var __prev_now_switch_msg: String = "xx"
## for the top state this is called from model
func _update(delta: float) -> void:
	call_accumulate_time_spent(delta)
	if works_longer_than_fatigue():
		me.fatigue_raised = true


	# do ur stuff
	update(delta)

	var verdict := _check_substate_transition(delta)

	# todo one big mess here
	if verdict.needs_switch():
		# if __state_declined != verdict.next_state:
		# 	if __ELA(): __log_phe_decision(verdict.get_reason(), " |", __get_common_context(), " => ", verdict.next_state)
		var _current_sbs := get_current_substate()
		if not verdict.override_commit_raised() and (_current_sbs != null and _current_sbs.works_less_than_commitment()):
			# if __state_declined != verdict.next_state:
			# 	if __ELA(): __log_phe_decision(em.pin, "curr sbs '%s' worked < %.2f commit, switch to '%s' declined ✖️. Curr sbs timings: %s" \
			# 		% [_current_sbs.state_name, _current_sbs.commitment, verdict.next_state, _current_sbs.__log_timings()])
			__state_declined = verdict.next_state
		else:
			__state_declined = "x"
			_switch_substate(verdict.next_state)
	# elif state_name != PHES._TOP and not self is BasePHEAttackSeries and __prev_now_switch_msg != verdict.get_reason():
		# if __ELA(): __log_phe_decision("NO SWITCH for", pp.in_q(get_safe_curr_sbs_name()), verdict.get_reason(), "Verdict data:", verdict)
		# __prev_now_switch_msg = verdict.get_reason()
		
	# call ur children to do stuff
	if get_current_substate() != null:
		get_current_substate()._update(delta)
	else:
		__log_error("_update: get_current_substate() is null, cannot update.")


func works_longer_than_fatigue() -> bool:
	return CommitCheck.works_longer_than_fatigue(self )

func works_less_than_commitment() -> bool:
	return CommitCheck.works_less_than_commitment(self )


## nullable
func get_current_substate() -> BasePHEState:
	return __current_substate


func get_current_substate_by_depth(depth: int) -> BasePHEState:
	if state_depth == depth:
		return self
		
	var _curr_substate := get_current_substate()
	if _curr_substate:
		return _curr_substate.get_current_substate_by_depth(depth)
	else:
		return null


func get_safe_curr_sbs_name() -> String:
	if __current_substate: return __current_substate.state_name
	return "-x-"


func set_current_substate(next_state_name: String) -> void:
	var _next_substate := container.get_state_by_name(next_state_name)
	if not _next_substate:
		__log_error(pp.s("set_current_substate: state not found", next_state_name), "", "return, not set")
		return

	if not _next_substate.validate_substate_depth(state_depth):
		__log_error(pp.s("set_current_substate: depth issue. Curr depth", state_depth, "next_state_name", next_state_name), "", "return, not set")
		return
	
	if not supported_substates.is_state_supported(next_state_name):
		__log_error(pp.s("set_current_substate: not supported. ", supported_substates.__pp_state_not_supported(next_state_name), state_depth), "", "return, not set")
		return

	__current_substate = _next_substate
	SigUtils.safe_emit_raw(
		GlobalSignal.SIG_phe_state_changed,
		{
			## changed to 
			SPS.h_state_data_field: GlobalSignal.HStateData.new(
					_next_substate.state_name,
					_next_substate.state_depth)
		}
	)


func reset_current_substate() -> void:
	SigUtils.safe_emit_raw(
		GlobalSignal.SIG_phe_state_reset,
		{
			## reset from
			SPS.h_state_data_field: GlobalSignal.HStateData.new(
					__current_substate.state_name,
					__current_substate.state_depth)
		}
	)
	__current_substate = null


## not to override
## wrapper around check_substate_transition, makes important checks
func _check_substate_transition(delta: float) -> VerdictPH:
	var _next_state := ""
	var _reason := ""
	var current_substate_ := get_current_substate()
	if not current_substate_: # DANGER: should not happen! very crucial
		__log_error("no current_substate_ in _check_substate_transition. returning empty verdict")
		return VerdictPH.new()
	var _sbs_verdict := check_substate_transition(delta, current_substate_, "", "")
	
	# NOTE: for now empty verdict means we don't switch from current state.
	#       but states can return the name explicitly, so we check this here.
	#       And if state returns the name explicitly, meaning new switch, it sets a flag
	if _sbs_verdict.next_state == current_substate_.state_name and not _sbs_verdict.switch_on_same_raised():
		_sbs_verdict.reset_next_state()
	elif _sbs_verdict.next_state == "" and _sbs_verdict.switch_on_same_raised():
		if __ELA(): __log_phe_check("Next state '' but needs switch. We explicitly assign curr subs", current_substate_.state_name)
		_sbs_verdict.next_state = current_substate_.state_name
	
	return _sbs_verdict


## not to override
func _choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var _initial_sbs_verdict := choose_initial_substate(_next_state, _reason)
	if not _initial_sbs_verdict.needs_switch():
		__log_warn_v2("returned empty verdict!", "choose_initial_substate", "return first supported sbs")
		_initial_sbs_verdict.next_state = supported_substates.get_first_one()
	return _initial_sbs_verdict


## usually overriden
## 'current_substate' - to work with to make a decisions. NOTE: guaranteed to be not null!
## '_next_state' - is empty string on function entry. State will fill it and set to verdict
## '_reason' - is empty string on function entry. State should fill it and add to verdict reason
## all this args could ve been initiated inside check_substate_transition, 
## but this way all function implementations are more uniformed and less verbose and prone to error
## NOTE: for simplicity, last line should be always 'return VerdictPH.new(_next_state, _reason)'
func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	if __ELA(): _reason = "default implementation"
	return VerdictPH.new(_next_state, _reason)


## '_next_state' - is empty string on function entry. State will fill it and set to verdict
## '_reason' - is empty string on function entry. State should fill it and add to verdict reason
## NOTE: for simplicity, last line should be always 'return VerdictPH.new(_next_state, _reason)'
func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	if __ELA(): _reason = em.crucial_x2 + "state must implement choose_initial_substate!"
	return VerdictPH.new(_next_state, _reason)


func _switch_substate(next_state_name: String):
	if get_current_substate() == null:
		if __ELA(): __log_phe("↪️", "-  x  -" + " -> " + next_state_name)
	else:
		if __ELA(): __log_phe("↪️", get_current_substate().state_name + " -> " + next_state_name)

	if get_current_substate() != null:
		get_current_substate()._on_exit_state()

	set_current_substate(next_state_name)
	
	get_current_substate()._on_enter_state()


func time_spent() -> float:
	return get_actual_time_spent()

func works_longer_than(time: float) -> bool:
	return get_actual_time_spent() > time

func works_less_than(time: float) -> bool:
	return get_actual_time_spent() < time


func react_on_hit(hit_data: HitData) -> void:
	var _curr_sbs := get_current_substate()
	if not _curr_sbs:
		__log_warn_v2("no _curr_sbs", "react_on_hit", "no hit applied, it's lost", hit_data)
		return
	_curr_sbs.react_on_hit(hit_data)


func is_apply_gravity() -> bool:
	var _curr_sbs := get_current_substate()
	if not _curr_sbs:
		__log_warn_v2("no _curr_sbs", "is_apply_gravity", "return true")
		return true
	return _curr_sbs.is_apply_gravity()

	
# region: __LOGS

func __log_indent() -> int:
	var _m: Dictionary[int, int] = {0: 0, 1: 1, 2: 3, 3: 5, 4: 8, 5: 10}
	return _m.get(state_depth, 18)

func __log_state() -> String:
	var _r := ""
	if state_name == PHES._TOP:
		_r += "☐"
	else:
		_r += "▨"
	_r += state_name
	_r += " "
	_r += pp.in_sq(str(state_depth))
	_r += "-> "
	var _curr_sbs := get_current_substate()
	_r += _curr_sbs.state_name if _curr_sbs else "-x-"
	return _r


func __log_timings() -> String:
	var _actual_time_spent := get_actual_time_spent()
	var _time_msg := ""
	_time_msg += pp.round_01(_actual_time_spent) + "| "

	return _time_msg

# endregion
