extends BasePHEState
class_name BasePHEComposite


var state_depth: int


## DANGER: do not use directly!
var __current_substate: BasePHEState = null


var __is_entered: bool = false


func validate_substate_depth(parent_depth: int) -> bool:
	return state_depth - parent_depth == 1


func _on_enter_state():
	mark_enter_state()

	me.update_state_history(state_name)

	if __is_entered:
		__log_warn(true, "Already entered")
	__is_entered = true

	
	var _next_state = ""
	var _reason = ""
	var initial_state_verdict = choose_initial_substate(_next_state, _reason)
	if not initial_state_verdict.needs_switch():
		__log_warn(true, "choose_initial_substate returned empty verdict!")
		return
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

	if get_current_substate() != null:
		get_current_substate()._on_exit_state()
		reset_current_substate()
	on_exit_state()


var __state_declined: String = "x"

## for the top state this is called from model
func _update(delta: float):
	accumulate_time_spent(delta)
	if works_longer_than_fatigue():
		me.fatigue_raised = true

	# do ur stuff
	update(delta)

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
	if get_current_substate() != null:
		get_current_substate()._update(delta)
	else:
		__log_warn(true, "_update: __current_substate is null, cannot update.")


func works_longer_than_fatigue() -> bool:
	return CommitCheck.works_longer_than_fatigue(self)

func works_less_than_commitment() -> bool:
	return CommitCheck.works_less_than_commitment(self)


func get_current_substate() -> BasePHEState:
	return __current_substate


func set_current_substate(next_state_name: String) -> void:
	var _next_substate = container.get_state_by_name(next_state_name)
	if not _next_substate:
		__log_warn(true, "set_current_substate: state not found", next_state_name, "!! won't set")
		return

	if not _next_substate.validate_substate_depth(state_depth):
		__log_warn(true, "substate_depth issue. Curr depth", state_depth, "next_state_name", next_state_name)

	__current_substate = _next_substate


func reset_current_substate() -> void:
	__current_substate = null


## not to override
## wrapper around check_substate_transition, makes important checks
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
	
	return _sbs_verdict


## usually overriden
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


func works_longer_than(time: float) -> bool:
	return get_actual_time_spent() > time

func works_less_than(time: float) -> bool:
	return get_actual_time_spent() < time


# region: __LOGS

func __log_indent() -> int:
	var _m = {0: 0, 1: 1, 2: 3, 3: 5, 4: 8, 5: 10}
	return _m.get(state_depth, 18)

func __log_state() -> String:
	var _r = ""
	if state_name == PHEState._TOP:
		_r += "☐"
	else:
		_r += "▨"
	_r += state_name
	_r += " "
	_r += pp.in_sq(str(state_depth))
	_r += "-> "
	var _curr_sbs = get_current_substate()
	_r += _curr_sbs.state_name if _curr_sbs else "-x-"
	return _r


func __log_timings() -> String:
	var _actual_time_spent = get_actual_time_spent()
	var _time_msg = ""
	_time_msg += pp.round_01(_actual_time_spent) + "| "

	return _time_msg

# endregion