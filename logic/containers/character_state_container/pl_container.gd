@tool
@icon("res://-assets-/x_icons/white/icon_grid.png")

extends BaseNodeCharacterSystem
class_name PlayerStatesContainer

var _player: Princess

@onready var legs_sm: LegsSM = %LegsSM
@onready var player_sm: PlayerSM = %PlayerSM
@onready var feelings: PlayerFeelings = %Feelings
@onready var combat: PlayerCombat = %Combat
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var anim_container: AnimationContainer = %AnimContainer
@onready var animator_manager: PlAnimatorManager = %AnimatorManager
@onready var anim_params_container: AnimParamsContainer = %AnimParamsContainer


func is_player() -> bool:
	return true


func _get_actions_by_state(state: String, states_container: StatesContainer) -> Array[StatesContainer._PlActionData]:
	var result: Array[StatesContainer._PlActionData] = []
	for action_data: StatesContainer._PlActionData in states_container.pl_action_data_list:
		if action_data.state_name == state:
			result.append(action_data)

	for action_data: StatesContainer._PlActionData in states_container.node_to_pl_action.values():
		if action_data.state_name == state:
			result.append(action_data)
	return result


var _states: Dictionary[String, BasePlayerState]

var _player_actions: Dictionary[String, PlayerAction]

var _legs_behaviors: Dictionary[String, LegsBehavior]

var _leg_actions: Dictionary[String, LegsAction]


## nullable
func state_by_name(state_name: String) -> BasePlayerState:
	var _r: BasePlayerState = u.safe_get_dict_key(_states, state_name, null)
	return _r


func pl_action_by_name(action_name: String) -> PlayerAction:
	var _r: PlayerAction = u.safe_get_dict_key(_player_actions, action_name, null)
	return _r


func l_behavior_by_name(behavior_name: String) -> LegsBehavior:
	var _r: LegsBehavior = u.safe_get_dict_key(_legs_behaviors, behavior_name, null)
	return _r

func l_action_by_name(action_name: String) -> LegsAction:
	var _r: LegsAction = u.safe_get_dict_key(_leg_actions, action_name, null)
	return _r


func accept_all_states(player_: Princess):
	_player = player_
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
		if not state_data:
			__log_warn("No state data found for: " + child.get_name(), "_accept_player_states", "Will be skipped")
			continue

		print_.container("", "state_data.state_name " + state_data.state_name)

		_states[state_data.state_name] = child

		# specific
		child.state_name = state_data.state_name
		child.priority = state_data.priority
		# legs behaviors should be already accepted
		child.legs_behavior = l_behavior_by_name(state_data.legs_behavior_name)
		child.depends_on_legs = state_data.depends_on_legs
		child.stamina_cost = state_data.stamina_cost
		
		var actions := _get_actions_by_state(state_data.state_name, states_container)
		if state_data.depends_on_legs:
			if actions.size() != 0:
				__log_error(pp.s("Actions found for dependent state. Expected zero", child.state_name, "Actions:", actions))
			# TODO: not default but supported? then array which is more universal. default will be choosen later
			child.default_action_name = ""
		else:
			if actions.size() == 0:
				__log_error("No actions found for state: " + child.state_name)
				child.default_action_name = ""
			else:
				child.default_action_name = actions[0].action_name

		var combos := get_descendants.combos_one_level(child)
		for combo: Combo_ in combos:
			print_.container("", pp.s("For state", child.state_name, "assigned combo", combo.name, "priority", combo.priority))
			combo.player = _player
		
		child.state_combos_sorted = _sort_combos_by_priority(combos)


		# common
		child._player = _player
		child.feelings = feelings
		child.combat = combat
		child.container = self
		child.area_awareness = area_awareness
		child.player_sm = player_sm
		child.legs_sm = legs_sm
		child.anim_container = anim_container
		child.animator_manager = animator_manager

		if not child.legs_behavior:
			__log_error("No legs_behavior assigned for state: " + child.state_name)
		if not child.state_name or child.state_name.is_empty():
			__log_error("No state_name assigned for state node: " + child.get_name())
		if child.priority == null or child.priority < 0:
			__log_error(pp.s("Invalid priority for state:", child.state_name, child.priority))

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
		var action_data: StatesContainer._PlActionData = states_container.node_to_pl_action.get(child.get_name())
		
		_player_actions[action_data.action_name] = child

		child.state_name = action_data.state_name

		__apply_base_action_data(action_data, child)
		
		
	print_.container("pl_act", "===========  Accepted actions ===========")
	print_.container("pl_act", str(_player_actions))
	print_.container("", "")


func __apply_base_action_data(action_data: StatesContainer._BaseActionData, child: BaseAction):
	child.action_name = action_data.action_name
	child.motion_type = action_data.motion_type
	child.player_sm = player_sm
	child.container = self
	child.feelings = feelings
	
	# anim data
	var anim := anim_container.get_by_anim_id(action_data.anim_id)
	if not anim:
		__log_error("No animation found for action: " + child.action_name + " with anim_id: " + action_data.anim_id)
	child.anim = anim
	child.animator_manager = animator_manager
	child.anim_container = anim_container
	child.anim_params_container = anim_params_container
	
	if not child.action_name or child.action_name.is_empty():
		__log_error("No action_name assigned for action: " + child.get_name())


func _accept_legs_behaviors():
	var leg_beh_container := LegBehaviorContainer.new()
	for child: LegsBehavior in get_descendants.legs_behaviors(legs_sm):
		print_.container("", "node.get_name() " + child.get_name())
		var behavior_data: LegBehaviorContainer._BehaviorData = leg_beh_container.node_to_l_behavior_data[child.get_name()]
		if not behavior_data:
			__log_warn("No behavior data found for: " + child.get_name() + " Will be skipped")
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

		if not child.behavior_name or child.behavior_name.is_empty():
			__log_error("No behavior_name assigned for behavior node: " + child.get_name())


func _accept_legs_actions():
	var leg_beh_container := LegBehaviorContainer.new()
	for child: LegsAction in get_descendants.legs_actions(legs_sm):
		print_.container("", "node.get_name() " + child.get_name())
		var action_data: LegBehaviorContainer._LActionData = leg_beh_container.node_to_l_action_data.get(child.get_name())
		if not action_data:
			__log_warn("No action data found for: " + child.get_name() + " Will be skipped")
			continue
		print_.container("", "action_data.action_name " + action_data.action_name)
		_leg_actions[action_data.action_name] = child
		
		# base action
		child.legs_sm = legs_sm
		__apply_base_action_data(action_data, child)

		if not child.action_name or child.action_name.is_empty():
			__log_error("No action_name assigned for legs action: " + child.get_name())


func states_sort_by_priority(state_names: Array[String]) -> Array[String]:
	# 0 means lowest
	var _safe_sorted: Array[String]
	for item in state_names:
		if u.safe_has_key(_states, item, WarnLevel.WARN_CRUCIAL):
			_safe_sorted.append(item)
	_safe_sorted.sort_custom(_states_priority_sort)
	return _safe_sorted


func _states_priority_sort(a: String, b: String) -> bool:
	if _states[a].priority > _states[b].priority:
		return true
	else:
		return false


## __LOGS
# region

func pp_name() -> String:
	return "PlayerStatesContainer"

func __LOG_B() -> bool:
	return LogToggler.CONTAINER_B

func __LOG_INDENT() -> int:
	return 0

# endregion