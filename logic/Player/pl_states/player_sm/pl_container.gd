@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")

extends Node
class_name PlayerStatesContainer

# -- set by model
var player: Princess

@onready var legs_sm: LegsSM = %LegsSM
@onready var player_sm: PlayerSM = %PlayerSM
@onready var feelings: PlayerFeelings = %Feelings
@onready var combat: PlayerCombat = %Combat
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var anim_container: AnimationContainer = %AnimContainer
@onready var animator_manager: PlAnimatorManager = %AnimatorManager
@onready var anim_params_container: AnimParamsContainer = %AnimParamsContainer


func _get_actions_by_state(state: String, states_container: StatesContainer) -> Array[StatesContainer._ActionData]:
	var result: Array[StatesContainer._ActionData] = []
	for action_data: StatesContainer._ActionData in states_container.pl_action_data_list:
		if action_data.state_name == state:
			result.append(action_data)

	for action_data: StatesContainer._ActionData in states_container.node_to_pl_action.values():
		if action_data.state_name == state:
			result.append(action_data)
	return result


var _states: Dictionary # { string : BasePlayerState }

var _player_actions: Dictionary # { string : PlayerAction }

var _legs_behaviors: Dictionary # { string : LegsBehavior }

var _leg_actions: Dictionary # { Node name : LegsAction }


func state_by_name(state_name: String) -> BasePlayerState:
	# if not _states.has(state_name):
	# 	print_.dev("ERROR =PSContainer=", "state_by_name: " + state_name + " not found")
	# 	push_error("ERROR =PSContainer= state_by_name: " + state_name + " not found")
	# 	return _states[PS.run]
	assert(_states.has(state_name), "_states dict doesn't have " + pp.in_q(state_name))
	return _states[state_name]


func pl_action_by_name(action_name: String) -> PlayerAction:
	assert(_player_actions.has(action_name), "_player_actions dict doesn't have " + action_name)
	return _player_actions[action_name]


func l_behavior_by_name(behavior_name: String) -> LegsBehavior:
	assert(_legs_behaviors.has(behavior_name), "_legs_behaviors dict doesn't have " + behavior_name)
	return _legs_behaviors[behavior_name]
	

func l_action_by_name(action_name: String) -> LegsAction:
	assert(_leg_actions.has(action_name), "_leg_actions dict doesn't have " + action_name)
	return _leg_actions[action_name]


func accept_all():
	_accept_legs_behaviors()
	_accept_player_states()
	_accept_player_actions()
	_accept_legs_actions()

	# specific set ups. Analogue of _ready()
	_initialise_pl_state()
	_initialise_pl_actions()
	_initialise_legs_actions()


func _initialise_pl_state():
	for state: BasePlayerState in _states.values():
		state.initialise()

func _initialise_pl_actions():
	for action: PlayerAction in _player_actions.values():
		action.initialise()

func _initialise_legs_actions():
	for action: LegsAction in _leg_actions.values():
		action.initialise()


func _accept_player_states() -> void:
	var states_container := StatesContainer.new()

	for child: BasePlayerState in get_descendants.player_states(player_sm):
		print_.container("", "child.get_name() " + child.get_name())
		var state_data: StatesContainer._StateData = states_container.node_to_pl_state_data.get(child.get_name())
		# assert(state_data, "StateData for " + child.get_name() + " not found")
		if not state_data:
			push_error("No state data found for: " + child.get_name())
			continue

		print_.container("", "state_data.state_name " + state_data.state_name)

		_states[state_data.state_name] = child

		# specific
		child.state_name = state_data.state_name
		child.priority = state_data.priority
		# legs behaviors should be already accepted (covered by assert)
		child.legs_behavior = l_behavior_by_name(state_data.legs_behavior_name)
		child.depends_on_legs = state_data.depends_on_legs
		child.stamina_cost = state_data.stamina_cost
		
		var actions := _get_actions_by_state(state_data.state_name, states_container)
		if state_data.depends_on_legs:
			assert(actions.size() == 0, "Actions found for dependent state: " + child.state_name + ". Actions:" + str(actions))
			# TODO: not default but supported? then array which is more universal. default will be choosen later
			child.default_action_name = ""
		else:
			assert(actions.size() > 0, "No actions found for state: " + child.state_name)
			child.default_action_name = actions[0].action_name

		var combos := get_descendants.combos_one_level(child)
		for combo: Combo_ in combos:
			print_.container("", pp.s("For state", child.state_name, "assigned combo", combo.name, "priority", combo.priority))
			combo.player = player
		
		child.state_combos_sorted = _sort_combos_by_priority(combos)


		# common
		child._player = player
		child.feelings = feelings
		child.combat = combat
		child.container = self
		child.area_awareness = area_awareness
		child.player_sm = player_sm
		child.legs_sm = legs_sm
		child.anim_container = anim_container
		child.animator_manager = animator_manager


		assert(child.legs_behavior, " legs_behavior problem for state: " + child.state_name)
		assert(child.state_name and not child.state_name.is_empty(), " state_name problem for state ")
		assert(child.priority and child.priority >= 0, " priority problem for state: " + child.state_name)

	print_.container("", "===========  Accepted states ===========")
	print_.container("", str(_states))
	print_.container("", "")


func _sort_combos_by_priority(combos: Array) -> Array:
	# 0 means lowest
	var sorted := combos.duplicate()
	sorted.sort_custom(func(a: Combo_, b: Combo_): return a.priority > b.priority)
	return sorted


func _accept_player_actions():
	var states_container := StatesContainer.new()
	
	for child: PlayerAction in get_descendants.player_actions(player_sm):
		print_.container("pl_act", "child.get_name() " + child.get_name())
		var action_data: StatesContainer._ActionData = states_container.node_to_pl_action.get(child.get_name())
		__apply_base_action_data(action_data, child)

	for action_data: StatesContainer._ActionData in states_container.pl_action_data_list:
		var node_name := u.to_pascal_case(action_data.action_name)
		print_.container("pl_act", "Creating action: " + action_data.action_name)
		var child := PlayerAction.new()
		child.name = node_name
		__apply_base_action_data(action_data, child)
		add_child(child) # add to tree
	
	print_.container("pl_act", "===========  Accepted actions ===========")
	print_.container("pl_act", str(_player_actions))
	print_.container("", "")


func __apply_base_action_data(action_data: StatesContainer._ActionData, child: BaseAction):
	_player_actions[action_data.action_name] = child
	
	# common
	child.player_sm = player_sm
	child.container = self
	child.animator_manager = animator_manager
	child.anim_container = anim_container
	child.player_sm = player_sm
	child.anim_params_container = anim_params_container
	
	# specific 
	var anim := anim_container.get_by_anim_id(action_data.anim_id)
	assert(anim, "no anim with " + action_data.anim_id)
	child.anim = anim
	child.action_name = action_data.action_name
	child.motion_type = action_data.motion_type
	
	assert(child.action_name and not child.action_name.is_empty(), "action_name problem")
	

func _accept_legs_behaviors():
	var leg_beh_container := LegBehaviorContainer.new()
	for child: LegsBehavior in get_descendants.legs_behaviors(legs_sm):
		print_.container("", "node.get_name() " + child.get_name())
		var behavior_data: LegBehaviorContainer._BehaviorData = leg_beh_container.node_to_l_behavior_data[child.get_name()]
		if not behavior_data:
			push_error("No behavior data found for: " + child.get_name())
			continue
		print_.container("", "behavior_data.behavior_name " + behavior_data.behavior_name)
		_legs_behaviors[behavior_data.behavior_name] = child

		# specific
		child.behavior_name = behavior_data.behavior_name
		child.supported_actions = behavior_data.supported_actions
		
		# common
		child.combat = combat
		child.legs_sm = legs_sm
		child.container = self
		child.area_awareness = area_awareness

		assert(child.behavior_name and not child.behavior_name.is_empty(), " behavior_name problem for behavior")


func _accept_legs_actions():
	var leg_beh_container := LegBehaviorContainer.new()
	for child: LegsAction in get_descendants.legs_actions(legs_sm):
		print_.container("", "node.get_name() " + child.get_name())
		var action_data: LegBehaviorContainer._ActionData = leg_beh_container.node_to_l_action_data.get(child.get_name())
		if not action_data:
			print_.warn_raw(false, "No action data found for: " + child.get_name() + " Will be skipped")
			continue
		print_.container("", "action_data.action_name " + action_data.action_name)
		_leg_actions[action_data.action_name] = child
		
		# base action
		child.legs_sm = legs_sm
		child.container = self
		child.anim_container = anim_container
		child.animator_manager = animator_manager
		child.player_sm = player_sm
		

		# specific
		var anim := anim_container.get_by_anim_id(action_data.anim_id)
		child.anim = anim
		child.action_name = action_data.action_name
		child.motion_type = action_data.motion_type

		assert(child.action_name and not child.action_name.is_empty(), "action_name problem for")

func states_sort_by_priority(state_names: Array[String]) -> Array[String]:
	# 0 means lowest
	var _safe_sorted: Array[String]
	for item in state_names:
		if u.safe_has_key(_states, item, Fallback.WARN_CRUCIAL):
			_safe_sorted.append(item)
	_safe_sorted.sort_custom(_states_priority_sort)
	return _safe_sorted


func _states_priority_sort(a: String, b: String) -> bool:
	if _states[a].priority > _states[b].priority:
		return true
	else:
		return false
