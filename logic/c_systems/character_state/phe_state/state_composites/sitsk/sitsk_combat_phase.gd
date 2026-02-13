extends BasePHEComposite
class_name SimpleCombat


func get_supported_substates() -> Array[String]:
	return [SITSKS.Leaf.sit_attack]


func is_ended() -> bool:
	var curr = get_current_substate()
	return curr != null and curr.is_ended()


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	PlayerStats.increase_count_sitting_sk_hit()
	return VerdictPH.new(SITSKS.Leaf.sit_attack, "only one attack")