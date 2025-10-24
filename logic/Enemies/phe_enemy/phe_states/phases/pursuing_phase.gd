extends BasePHState

var pursuit_radius: float = 8


func check_transition(_delta) -> VerdictPH:
	match current_lower_state.state_name:
		PHEState.orbit:
			if distance_to_player() > pursuit_radius:
				return VerdictPH.new(PHEState.pursue)
		PHEState.pursue:
			if distance_to_player() < pursuit_radius:
				return VerdictPH.new(PHEState.orbit)

	return VerdictPH.new()


func choose_internal_state() -> VerdictPH:
	if distance_to_player() > pursuit_radius:
		return VerdictPH.new(PHEState.pursue)
	return VerdictPH.new(PHEState.orbit)
