extends BasePHEComposite
class_name PHEStillLifePhase


var _is_awaken: bool = false


func get_supported_substates() -> Array[StringName]:
	return [
			PHES.Leaf.sleep,
			PHES.Leaf.awaken,
		]


func is_ended() -> bool:
	return _is_awaken

func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: StringName, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		PHES.Leaf.sleep:
			if _awake_condition():
				if __LOG_B(): _reason += "_awake_condition"
				_next_state = PHES.Leaf.awaken
		# todo: its more like in update() should be now
		PHES.Leaf.awaken:
			if current_substate.time_remaining() <= 0.3:
				if __LOG_B(): __log_phe_check("finished awaken anim")
				_is_awaken = true
				SigUtils.safe_emit_no_payload(me.SIG_awaken)

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "will be in current sbs + _is_awaken true")
			_is_awaken = true
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: StringName, _reason: String) -> VerdictPH:
	_next_state = PHES.Leaf.sleep
	if __LOG_B(): _reason += "initial still_life state"
	return VerdictPH.new(_next_state, _reason)


func _awake_condition() -> bool:
	return distance_to_player() < config.DIST_TO_AWAKE
