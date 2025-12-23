@tool
extends Combo_

class_name NextStateCombo

@export_group("Inputs")
## NOTE: field could be not equal to state_to_trigger.
##       Input is a state names, but not all states can be described as input
##       (hence all the contextualizers and combos)
## NOTE: for attacks setting needs_combat_input might be enough.
@export var needs_input: String = "not"
@export var needs_combat_input: String = "not"

@export_group("Queue")
@export var needs_allows_queue: bool = true

@export_group("Time Management")
## empty string means no marker needed
## if marker doens't exist, combo won't be triggered
@export var needs_passed_marker: String = "not"
@export var needs_time_in_action: float = 0.0

@export_group("__dev")
@export var __log_false_decision: bool = false


func _needs_curr_action_is_set() -> bool:
	return needs_curr_action != "not"

func _needs_input_is_set() -> bool:
	return needs_input != "not"

func _needs_combat_input_is_set() -> bool:
	return needs_combat_input != "not"

func _needs_allows_queue_is_set() -> bool:
	return needs_allows_queue

func _needs_passed_marker_is_set() -> bool:
	return needs_passed_marker != "not"

func _needs_time_in_action_is_set() -> bool:
	return needs_time_in_action > 0.0


func is_triggered(input_: InputPackage, curr_state_name: String, curr_action: BaseAction) -> bool:
	var decision: bool = true
	
	## state
	if curr_state_name != needs_curr_state:
		decision = false
	
	if _needs_curr_action_is_set() and curr_action.action_name != needs_curr_action:
		decision = false
	
	## input
	if _needs_input_is_set() and not input_.actions.has(needs_input):
		decision = false
		
	if _needs_combat_input_is_set() and not input_.combat_actions.has(needs_combat_input):
		decision = false
	
	##
	if _needs_allows_queue_is_set() and not curr_action.allows_queue():
		decision = false
	
	## time management
	if _needs_passed_marker_is_set():
		if not curr_action.anim.does_marker_exist(needs_passed_marker):
			print_.note(false, "needs_passed_marker not exists for anim", needs_passed_marker, "NextStateCombo", "combo won't be triggered")
			decision = false
		elif not curr_action.passed_marker(needs_passed_marker):
			decision = false
	
	if _needs_time_in_action_is_set() and curr_action.works_less_than(needs_time_in_action):
		decision = false
	
	__log_next_state_combo_decision(decision, input_, curr_state_name, curr_action)
	return decision


func __log_next_state_combo_decision(decision: bool, input_: InputPackage, curr_state_name: String, curr_action: BaseAction) -> void:
	if not __log_false_decision and not decision:
		return

	var _prefix := "triggered 🖲️"
	
	var _msg := "NEEDS/GOT "
	_msg += pp.s("St", needs_curr_state, "/", curr_state_name)

	if _needs_curr_action_is_set():
		_msg += pp.s("Act", needs_curr_action, "/", curr_action.action_name)
		
	if _needs_input_is_set():
		_msg += pp.s("Inp", needs_input, "/", pp.in_q(input_.actions))
	if _needs_combat_input_is_set():
		_msg += pp.s("CmbInp", needs_combat_input, "/", pp.in_q(input_.combat_actions))

	if _needs_allows_queue_is_set():
		_msg += pp.s("allowsQ ", pp.in_q(curr_action.allows_queue()))

	if _needs_passed_marker_is_set():
		_msg += pp.s("Mkr", needs_passed_marker)
		if curr_action.anim.does_marker_exist(needs_passed_marker):
			_msg += pp.s("/MarkTime", curr_action.anim.get_marker_time_by_name(needs_passed_marker))
		else:
			_msg += "/No marker!"
	if _needs_time_in_action_is_set():
		_msg += pp.s("time", needs_time_in_action, "/", curr_action.time_spent())
	
	
	# always log
	_msg += pp.s("| timeSpent", curr_action.time_spent())
	
	__log_(name + _prefix,
			pp.s(
			"st2trigger", state_to_trigger,
			_msg,
			"=>", decision))
