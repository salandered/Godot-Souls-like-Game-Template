@tool
extends Combo_

class_name NextStateCombo

## NOTE: state_name, not node name
@export var needs_curr_state: String

## NOTE: field could be not equal to state_to_trigger.
##       Input is a state names, but not all states can be described as input
##       (hence all the contextualizers and combos)
@export var needs_input: String

@export var needs_allows_queue: bool = true


func is_triggered(input_: InputPackage, curr_state_name: String, curr_action: BaseAction) -> bool:
	var decision: bool = true
	if needs_allows_queue and not curr_action.allows_queue():
		decision = false
	if not input_.actions.has(needs_input):
		decision = false
	if curr_state_name != needs_curr_state:
		decision = false
	__log_next_state_combo_decision(decision, input_, curr_state_name, curr_action)
	return decision


func __log_next_state_combo_decision(decision: bool, input_: InputPackage, curr_state_name: String, curr_action) -> void:
	if decision == false:
		return
	var _prefix = " triggered 🖲️" if decision else " not triggered" + em.gray_x
	print_.combo(name + _prefix,
			pp.s("inpActions", input_.actions,
			"currAct", curr_action.action_name,
			"currSt", curr_state_name,
			"neededCurrSt", needs_curr_state,
			"needsAllowsQueue", needs_allows_queue,
			"neededInp", needs_input,
			"st2trigger", state_to_trigger,
			"=>", decision))
