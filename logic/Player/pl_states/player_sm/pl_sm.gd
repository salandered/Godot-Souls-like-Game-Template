extends Node
class_name PlayerSM

@export var combat: PlayerCombat
@export var area_awareness: AreaAwareness
@export var legs_sm: LegsSM

var player: Princess

@export var animator_manager: AnimatorManager
@export var animation_settings: AnimationPlayer
@onready var container: PlayerStatesContainer = %StatesContainer
@onready var player_movement: PlayerMovement = %PlayerMovement


var _transfer_data: TranferData = TranferData.new()


var current_state: PlayerState

var _current_action: BaseAction
var _prev_action: BaseAction


func initialise():
	var empty_input := InputPackage.new()

	var _idle_action := container.legs_action_by_name(Leg.Act.idle)
	var _double_st_action := container.action_by_name(PS.Act.double)
	var _run_state := container.state_by_name(PS.run)
	var _run_beh := container.legs_behavior_by_name(Leg.Beh.run)
	
	# global level
	current_state = _run_state
	_current_action = _idle_action
	_prev_action = _idle_action

	# state level
	current_state.curr_state_action = _double_st_action

	# legs sm level
	legs_sm.current_behavior = _run_beh
	legs_sm.current_action = _idle_action

	#
	animation_settings.play(A.SET_full_body, 0.2) # todo: delete


# TODO: fast solution. Design proper action (or states) ability to share data.
## for now its supposed to store only prev action data
## so actions can only use these methods for working with tranfer data
func fill_tranfer_data(tranfer_turn_data):
	## auto setting current action
	_transfer_data.fill(_current_action.action_name, tranfer_turn_data)


func get_tranfer_data_by_key(key) -> Variant:
	## auto getting prev one
	var data = _transfer_data.get_by_action_and_key(_prev_action.action_name, key)
	return data


func get_current_action() -> BaseAction:
	return _current_action


func get_prev_action() -> BaseAction:
	return _prev_action


func update_current_action(next_action: BaseAction):
	# var curr_act_name = ""
	# if not _current_action:
		# curr_act_name = "-none-"
		# print_.prefix(em.pin, "no _current_action. Should happen only on start up.")
	# else:
	var curr_act_name = _current_action.action_name
		
	var next_act_name = next_action.action_name

	if next_act_name == Leg.Act.double:
		print_.prefix(em.pin, "✖️ declined legs double update to curr. staying with " + curr_act_name)
		return
	if next_act_name == PS.Act.double:
		print_.prefix(em.pin, "✖️ declined state double update to curr. staying with " + curr_act_name)
		return

	if next_act_name == curr_act_name:
		print_.prefix(em.pin, "✖️🚸 came with the same action " + curr_act_name)

	print_.prefix(em.pin, curr_act_name + " moved to prev")
	print_.prefix(em.pin, next_act_name + " is set for curr")
	
	_prev_action = _current_action
	_current_action = next_action
	if _prev_action and next_act_name == _prev_action.action_name:
		print_.prefix(em.pin, em.red_x + "new curr equal prev! " + next_act_name)


func update(input_: InputPackage, delta: float) -> void:
	input_ = combat.contextualize(input_)
	input_ = area_awareness.contextualize(input_)
	area_awareness.last_input_package = input_

	var verdict := current_state._check_transition(input_)
	verdict._speak_freely()

	if verdict.needs_switch():
		print('\n')
		print_.psm("↪️", current_state.state_name + " => " + verdict.next_state)
		
		current_state._on_exit_state()
		# now current_state is next state
		current_state = container.state_by_name(verdict.next_state)
		current_state._on_enter_state(input_)

	# TODO: moved back here, Player States triggers _update from legs_animator behavior -> double dipping
	# current_state.update_resources(delta)
	current_state._update(input_, delta)
