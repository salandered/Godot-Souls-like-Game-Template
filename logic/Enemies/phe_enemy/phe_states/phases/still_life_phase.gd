extends BasePHEState
class_name PHEStillLifePhase

var _is_awaken: bool = false

var _to_awake: bool = false


func is_ended() -> bool:
	return _is_awaken

func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		PHEState.Leaf.sleep:
			if _to_awake:
				_reason = "_to_awake is true"
				_next_state = PHEState.Leaf.awaken
		# todo: its more like in update() should be now
		PHEState.Leaf.awaken:
			if current_substate.time_remaining() <= 0.3:
				__log_phe_check("finished awaken anim")
				_is_awaken = true

	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	_next_state = PHEState.Leaf.sleep
	_reason = "initial still life state"
	return VerdictPH.new(_next_state, _reason)


func _unhandled_input(event):
	if event.is_action_pressed("awake Gundyr"):
		_to_awake = true
