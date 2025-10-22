@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_propeller.png")
extends Combo_

## Consider renaming: For now it seems like it's NextState combo, 
##    not necessarily dealing with attacks 
class_name AttackCombo

## NOTE: state_name, not node name
@export var needs_curr_state: String

## NOTE: field could be not equal to state_to_trigger.
##       Input is a state names, but not all states can be described as input
##       (hence all the contextualizers and combos)
@export var needs_input: String

@export var needs_allows_queue: bool = true


func is_triggered(input_: InputPackage, curr_state_name: String, curr_act: BaseAction) -> bool:
	var decision: bool = true
	if needs_allows_queue and not curr_act.allows_queue():
		decision = false
	if not input_.actions.has(needs_input):
		decision = false
	if curr_state_name != needs_curr_state:
		decision = false
	__log_att_combo_decision(decision, input_, curr_state_name, curr_act)
	return decision


func __log_att_combo_decision(decision: bool, input_: InputPackage, curr_state_name: String, curr_act) -> void:
	if decision == false:
		return
	var _prefix = " triggered 🖲️" if decision else " not triggered" + em.gray_x
	print_.combo(name + _prefix,
			pp.s("inpActions", input_.actions,
			"currAct", curr_act.action_name,
			"currSt", curr_state_name,
			"neededCurrSt", needs_curr_state,
			"needsAllowsQueue", needs_allows_queue,
			"neededInp", needs_input,
			"st2trigger", state_to_trigger,
			"=>", decision))
