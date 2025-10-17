extends PlayerState

@export var sprint_stamina_cost = 20 # per sec so multiply by delta


func check_transition(input: InputPackage) -> PLVerdict:
	if not player.is_on_floor():
		return PLVerdict.new(PS.midair)
	return best_next_state_from_input(input)
