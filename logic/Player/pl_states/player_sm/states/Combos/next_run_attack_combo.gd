@tool
extends Combo_
class_name NextRunAttackCombo

## state_name, not node name
@export var needs_curr_state: String = PS.sprint
@export var needs_curr_action: String = Leg.Act.sprint

@export var needs_combat_input: String = CombatAction.light_attack_pressed_when_move

@export var time_in_action_needed: float = 0.2


func is_triggered(input_: InputPackage, curr_state_name: String, curr_acttion: BaseAction) -> bool:
	var decision: bool = true
	if curr_state_name != needs_curr_state:
		decision = false
	if not curr_acttion.action_name == needs_curr_action:
		decision = false
	if not input_.combat_actions.has(needs_combat_input):
		decision = false
	if curr_acttion.works_less_than(time_in_action_needed):
		decision = false
	__log_next_state_combo_decision(decision, input_, curr_state_name, curr_acttion)
	return decision


func __log_next_state_combo_decision(decision: bool, input_: InputPackage, curr_state_name: String, curr_action) -> void:
	if decision == false:
		return
	var _prefix = " triggered 🖲️" if decision else " not triggered" + em.gray_x
	print_.combo(name + _prefix,
			pp.s(
			"st2trigger", state_to_trigger,
			"NEEDS:",
				"St/Act", needs_curr_state, needs_curr_action,
				"timeInAct", time_in_action_needed,
				"CmbInp", needs_combat_input,
			"|",
			"GOT:",
				"St/Act", curr_state_name, curr_action.action_name,
				"timeSpent", curr_action.time_spent(),
				"inpComabtActions", input_.combat_actions,
			"=>", decision))
