extends BasePHEState

var PURSUIT_RAD: float = 16
var SLOW_PURSUIT_RAD: float = 8
var ORBIT_RAD: float = 6


var idle_for = PHEHelpers.WillDoFor.new(0.8, 2, PHEState.Leaf.combat_idle)

func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
	_next_state = _verdict.next_state
	_reason = _verdict._reason

	# close and decided to orbit - may be idle
	match current_substate.state_name:
		PHEState.Leaf.combat_idle:
			if _next_state == PHEState.Leaf.orbit and not idle_for.is_done(current_substate):
				_reason += " " + "will be in idle a bit longer"
				_next_state = ""
		_:
			if _next_state == PHEState.Leaf.orbit:
				if ra.coinflip():
					idle_for.set_random()
					_reason += " coin-flipped: " + idle_for.__pp_set_random()
					_next_state = PHEState.Leaf.combat_idle
				# else:
					# print_.note(" coin-flOpped: ", true)
	return VerdictPH.new(_next_state, _reason)


func _distance_to_pursue_sbs(_next_state, _reason):
	if distance_to_player() >= SLOW_PURSUIT_RAD:
		_next_state = PHEState.Leaf.pursue
		_reason = "distance_to_player() >= SLOW_PURSUIT_RAD " + str(SLOW_PURSUIT_RAD)
	elif distance_to_player() >= ORBIT_RAD:
		_reason = "distance_to_player() >= ORBIT_RAD " + str(ORBIT_RAD)
		_next_state = PHEState.Leaf.slow_pursue
	else: # < ORBIT_RAD
		_reason = "distance_to_player() < ORBIT_RAD " + str(ORBIT_RAD)
		_next_state = PHEState.Leaf.orbit
	
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var _verdict = _distance_to_pursue_sbs(_next_state, _reason)
	_next_state = _verdict.next_state
	_reason = _verdict._reason
	return VerdictPH.new(_next_state, _reason)
