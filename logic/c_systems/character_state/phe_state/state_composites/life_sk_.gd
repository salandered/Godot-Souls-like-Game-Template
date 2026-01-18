extends BasePHEComposite
class_name SimpleLife

var _was_just_hit: bool = false

func get_supported_substates() -> Array[String]:
	return [SITSKS.still_life_phase, SITSKS.combat_phase]


# mutes propagation
func react_on_hit(hit_data: HitData) -> void:
	if get_safe_curr_sbs_name() == SITSKS.still_life_phase:
		_was_just_hit = true


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	match current_substate.state_name:
		SITSKS.still_life_phase:
			if _was_just_hit:
				_next_state = SITSKS.combat_phase
				_was_just_hit = false
				
		SITSKS.combat_phase:
			# If the single attack is done, go back to sitting
			if current_substate.is_ended():
				_next_state = SITSKS.still_life_phase


	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	return VerdictPH.new(SITSKS.still_life_phase, "Start peaceful")
