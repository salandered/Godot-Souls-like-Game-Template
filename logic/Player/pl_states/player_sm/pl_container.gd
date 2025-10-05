@tool
@icon("res://-assets-/x_misc/x_icons/icon_grid.png")

extends Node
class_name PlayerStatesContainer

# -- set by model
var player: Princess


# @export var skeleton: Skeleton3D
@export var resources: HumanoidResources
@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var left_wrist: BoneAttachment3D

@export_group("SM")
@export var legs_sm: LegsSM
@export var player_sm: PlayerSM

@export_group("animation")
@export var anim_container: AnimationContainer
@onready var animator_manager: AnimatorManager = %AnimatorManager


func _get_actions_by_state(state: String, states_container: StatesContainer) -> Array[StatesContainer.ActionData]:
	var result: Array[StatesContainer.ActionData] = []
	for action_data: StatesContainer.ActionData in states_container.node_to_player_action_data.values():
		if action_data.state_name == state:
			result.append(action_data)
	return result


var _states: Dictionary # { string : PlayerState }

var _player_actions: Dictionary # { string : PlayerAction }

var _legs_behaviors: Dictionary # { string : LegsBehavior }

var _leg_actions: Dictionary # { Node name : LegsAction }


func state_by_name(state_name: String) -> PlayerState:
	# if not _states.has(state_name):
	# 	print_.prefix("ERROR =PSContainer=", "state_by_name: " + state_name + " not found")
	# 	push_error("ERROR =PSContainer= state_by_name: " + state_name + " not found")
	# 	return _states[PS.run]
	assert(_states.has(state_name), "_states dict doesn't have " + state_name)
	return _states[state_name]


func action_by_name(action_name: String) -> PlayerAction:
	assert(_player_actions.has(action_name), "_player_actions dict doesn't have " + action_name)
	return _player_actions[action_name]


func legs_behavior_by_name(behavior_name: String) -> LegsBehavior:
	assert(_legs_behaviors.has(behavior_name), "_legs_behaviors dict doesn't have " + behavior_name)
	return _legs_behaviors[behavior_name]
	

func legs_action_by_name(action_name: String) -> LegsAction:
	assert(_leg_actions.has(action_name), "_leg_actions dict doesn't have " + action_name)
	return _leg_actions[action_name]


func accept_player_states() -> void:
	var states_container = StatesContainer.new()

	for child: PlayerState in get_descendants.player_states_by_type(player_sm, "PlayerState"):
		print_.container("", "child.get_name() " + child.get_name())
		var state_data: StatesContainer.StateData = states_container.node_to_player_state_data.get(child.get_name())
		# assert(state_data, "StateData for " + child.get_name() + " not found")
		if not state_data:
			push_error("No state data found for: " + child.get_name())
			continue

		print_.container("", "state_data.state_name " + state_data.state_name)

		_states[state_data.state_name] = child

		child.state_name = state_data.state_name
		child.priority = state_data.priority
		# legs behaviors should be already accepted (covered by assert)
		child.legs_behavior = legs_behavior_by_name(state_data.legs_behavior_name)
		child.depends_on_legs = state_data.depends_on_legs
		
		var actions := _get_actions_by_state(state_data.state_name, states_container)
		if state_data.depends_on_legs:
			assert(actions.size() == 0, "Actions found for dependent state: " + child.state_name + ". Actions:" + str(actions))
			# TODO: not default but supported? then array which is more universal. default will be choosen later
			child.default_action_name = ""
		else:
			assert(actions.size() > 0, "No actions found for state: " + child.state_name)
			child.default_action_name = actions[0].action_name

		child.player = player
		child.resources = resources
		child.left_wrist = left_wrist
		child.combat = combat
		child.container = self
		child.area_awareness = area_awareness
		child.player_sm = player_sm
		child.legs_sm = legs_sm
		child.anim_container = anim_container
		child.animator_manager = animator_manager

		var combos := get_descendants.combos_one_level(child)
		for combo: Combo_ in combos:
			print_.container("", "For state " + child.state_name + " assigned combo " + combo.name)
			combo.player = player
		
		child.state_combos = combos

		assert(child.legs_behavior, " legs_behavior problem for state: " + child.state_name)
		assert(child.state_name and not child.state_name.is_empty(), " state_name problem for state ")
		assert(child.priority and child.priority >= 0, " priority problem for state: " + child.state_name)

	print_.container("", "===========  Accepted states ===========")
	print_.container("", str(_states))
	print("")


func accept_player_actions():
	var states_container = StatesContainer.new()

	for child: PlayerAction in get_descendants.player_states_by_type(player_sm, "PlayerAction"):
		print_.container("", "child.get_name() " + child.get_name())
		var action_data: StatesContainer.ActionData = states_container.node_to_player_action_data.get(child.get_name())
		if not action_data:
			print_.warn("No action data found for: " + child.get_name() + " Will be skipped")
			continue
		print_.container("", "action_data.action_name " + action_data.action_name)

		_player_actions[action_data.action_name] = child
		
		# base action
		child.player = player
		child.player_sm = player_sm
		child.container = self
		child.animator_manager = animator_manager
		child.anim_container = anim_container

		# specific
		var anim := anim_container.get_by_name(action_data.anim_id)
		assert(anim, "no anim with " + action_data.anim_id)
		child.anim = anim
		child.action_name = action_data.action_name

		assert(child.action_name and not child.action_name.is_empty(), " action_name problem")

	print_.container("", "===========  Accepted actions ===========")
	print_.container("", str(_player_actions))
	print("")


func accept_legs_behaviors():
	var leg_beh_container = LegBehaviorContainer.new()
	for child: LegsBehavior in get_descendants.player_states_by_type(legs_sm, "LegsBehavior"):
		print_.container("", "node.get_name() " + child.get_name())
		var behavior_data: LegBehaviorContainer.BehaviorData = leg_beh_container.node_to_behavior_data[child.get_name()]
		if not behavior_data:
			push_error("No behavior data found for: " + child.get_name())
			continue
		print_.container("", "behavior_data.behavior_name " + behavior_data.behavior_name)
		_legs_behaviors[behavior_data.behavior_name] = child

		# specific
		child.behavior_name = behavior_data.behavior_name
		child.supported_actions = behavior_data.supported_actions
		
		# common
		child.player = player
		child.combat = combat
		child.legs_sm = legs_sm
		child.container = self
		child.area_awareness = area_awareness

		assert(child.behavior_name and not child.behavior_name.is_empty(), " behavior_name problem for behavior")


func accept_legs_actions():
	var leg_beh_container = LegBehaviorContainer.new()
	for child: LegsAction in get_descendants.player_states_by_type(legs_sm, "LegsAction"):
		print_.container("", "node.get_name() " + child.get_name())
		var action_data: LegBehaviorContainer.ActionData = leg_beh_container.node_to_action_data.get(child.get_name())
		if not action_data:
			print_.warn("No action data found for: " + child.get_name() + " Will be skipped")
			continue
		print_.container("", "action_data.action_name " + action_data.action_name)
		_leg_actions[action_data.action_name] = child
		
		# base action
		child.player = player
		child.legs_sm = legs_sm
		child.container = self
		child.anim_container = anim_container
		child.animator_manager = animator_manager


		# specific
		var anim := anim_container.get_by_name(action_data.anim_id)
		child.anim = anim
		
		child.action_name = action_data.action_name
		child.motion_type = action_data.motion_type

		assert(child.action_name and not child.action_name.is_empty(), "action_name problem for")
		

func states_priority_sort(a: String, b: String) -> bool:
	if _states[a].priority > _states[b].priority:
		return true
	else:
		return false
