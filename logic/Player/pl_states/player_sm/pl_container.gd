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

var _player_state_data: Dictionary = { # { Node name : PSData }
	# move
	# "Walk": PSData.new(PS.walk, 2),
	# TODO: seems like depends_on_legs_ true equails to having not legs_double_beh default
	"Idle": PSData.new(PS.idle, 1, Leg.Beh.idle, true),
	"Run": PSData.new(PS.run, 2, Leg.Beh.run, true),
	"Strafe": PSData.new(PS.strafe, 3),
	"Sprint": PSData.new(PS.sprint, 3, Leg.Beh.sprint, true),
	"JumpRun": PSData.new(PS.jump_run, 10),
	"JumpSprint": PSData.new(PS.jump_sprint, 10),
	"Midair": PSData.new(PS.midair, 10),
	"LandingRun": PSData.new(PS.landing_run, 10),
	"LandingSprint": PSData.new(PS.landing_sprint, 10),
	"Roll": PSData.new(PS.roll, 20),
	"Death": PSData.new(PS.death, 200),
	# fight
	"Longsword1": PSData.new(PS.longsword_1, 15),
	"Longsword2": PSData.new(PS.longsword_2, 15),
	"Block": PSData.new(PS.block, 21, Leg.Beh.run),
	"BlockReaction": PSData.new(PS.block_reaction, 90),
	"Withdraw": PSData.new(PS.withdraw, 15),
	"ShieldThrow": PSData.new(PS.shield_throw, 16),
	"ShieldThrowReload": PSData.new(PS.shield_throw_reload, 17),
	"Pushback": PSData.new(PS.pushback, 101),
	"Staggered": PSData.new(PS.staggered, 100),
	"Parry": PSData.new(PS.parry, 20),
	"Parried": PSData.new(PS.parried, 100),
	"Riposte": PSData.new(PS.riposte, 25),

}

var _player_action_data: Dictionary = { # { Node name : PlayerActionData }
	# move
	# "Walk": PlayerActionData.new(PS.walk,PS.action_block, A.walk ),
	"StrafeAction": PlayerActionData.new(PS.strafe, PS.action_strafe, A.run_R),
	"JumpRunAction": PlayerActionData.new(PS.jump_run, PS.action_jump_run, A.jump_run),
	"JumpSprintAction": PlayerActionData.new(PS.jump_sprint, PS.action_jump_sprint, A.jump_sprint),
	"MidairAction": PlayerActionData.new(PS.midair, PS.action_midair, A.midair),
	"LandingRunAction": PlayerActionData.new(PS.landing_run, PS.action_landing_run, A.landing_run),
	"LandingSprintAction": PlayerActionData.new(PS.landing_sprint, PS.action_landing_sprint, A.landing_sprint),
	"RollAction": PlayerActionData.new(PS.roll, PS.action_roll, A.roll),
	"DeathAction": PlayerActionData.new(PS.death, PS.action_death, A.death),
	# fight
	"Longsword1Action": PlayerActionData.new(PS.longsword_1, PS.action_longsword_1, A.longsword_1),
	"Longsword2Action": PlayerActionData.new(PS.longsword_2, PS.action_longsword_2, A.longsword_2),
	"BlockAction": PlayerActionData.new(PS.block, PS.action_block, A.block_forward),
	"BlockReactionAction": PlayerActionData.new(PS.block_reaction, PS.action_block_reaction, A.block_reaction),
	"WithdrawAction": PlayerActionData.new(PS.withdraw, PS.action_withdraw, A.withdraw),
	"ShieldThrowAction": PlayerActionData.new(PS.shield_throw, PS.action_shield_throw, A.shield_throw),
	"ShieldThrowReloadAction": PlayerActionData.new(PS.shield_throw_reload, PS.action_shield_throw_reload, A.shield_throw_reload),
	"PushbackAction": PlayerActionData.new(PS.pushback, PS.action_pushback, A.pushback),
	"StaggeredAction": PlayerActionData.new(PS.staggered, PS.action_staggered, A.staggered),
	"ParryAction": PlayerActionData.new(PS.parry, PS.action_parry, A.parry),
	"ParriedAction": PlayerActionData.new(PS.parried, PS.action_parried, A.parried),
	"RiposteAction": PlayerActionData.new(PS.riposte, PS.action_riposte, A.riposte_attack),
}

func _get_actions_by_state(state: String) -> Array[PlayerActionData]:
	var result: Array[PlayerActionData] = []
	for node_ in _player_action_data.keys():
		var action_data: PlayerActionData = _player_action_data[node_]
		if action_data.state_name == state:
			result.append(action_data)
	return result


var _legs_behavior_data: Dictionary = {
	"IdleLegs": LegBehaviorData.new(Leg.Beh.idle),
	"RunLegs": LegBehaviorData.new(Leg.Beh.run),
	"SprintLegs": LegBehaviorData.new(Leg.Beh.sprint),
	# "AirLegs": LegBehaviorData.new(Leg.legs_air_behavior),
	"DoubleLegs": LegBehaviorData.new(Leg.Beh.double),
}

var _legs_action_data: Dictionary = {
	"IdleAction": LegActionData.new(Leg.Act.idle, A.combat_idle, MotionType.IDLE),
	"WalkStartAction": LegActionData.new(Leg.Act.walk_start, A.combat_walk_start, MotionType.START),
	"IdleToSprintAction": LegActionData.new(Leg.Act.idle_to_sprint, A.combat_idle_to_sprint, MotionType.START),
	# "RunToSprintAction": LegActionData.new(Leg.Act.run_to_sprint, A.combat_sprint_start,  MotionType.START),
	"RunAction": LegActionData.new(Leg.Act.run, A.combat_run, MotionType.LOOP),
	"SprintAction": LegActionData.new(Leg.Act.sprint, A.combat_sprint, MotionType.LOOP),
	"DoubleAction": LegActionData.new(Leg.Act.double, A.fake_anim, MotionType.IDLE),
}


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
	for child: PlayerState in get_descendants.player_states_by_type(player_sm, "PlayerState"):
		print_.container("", "child.get_name() " + child.get_name())
		var state_data: PSData = _player_state_data.get(child.get_name())
		# assert(state_data, "PSData for " + child.get_name() + " not found")
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
		
		# var actions := _get_state_descendants(child)
		var actions := _get_actions_by_state(state_data.state_name)
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
	for child: PlayerAction in get_descendants.player_states_by_type(player_sm, "PlayerAction"):
		print_.container("", "child.get_name() " + child.get_name())
		var action_data: PlayerActionData = _player_action_data.get(child.get_name())
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
		child.anim = anim
		child.anim_id = anim.anim_id
		child.anim_name = anim.anim_name
		child.DURATION = anim.duration
		child.action_name = action_data.action_name

		assert(child.action_name and not child.action_name.is_empty(), " action_name problem")
		assert(child.anim_id and not child.anim_id.is_empty(), " animation problem for action: " + child.action_name)
	print_.container("", "===========  Accepted actions ===========")
	print_.container("", str(_player_actions))
	print("")


func accept_legs_behaviors():
	for child: LegsBehavior in get_descendants.player_states_by_type(legs_sm, "LegsBehavior"):
		print_.container("", "node.get_name() " + child.get_name())
		var behavior_data: LegBehaviorData = _legs_behavior_data.get(child.get_name())
		if not behavior_data:
			push_error("No behavior data found for: " + child.get_name())
			continue
		print_.container("", "behavior_data.behavior_name " + behavior_data.behavior_name)
		_legs_behaviors[behavior_data.behavior_name] = child

		child.behavior_name = behavior_data.behavior_name

		child.player = player
		child.combat = combat
		child.legs_sm = legs_sm
		child.container = self
		child.area_awareness = area_awareness

		assert(child.behavior_name and not child.behavior_name.is_empty(), " behavior_name problem for behavior")


func accept_legs_actions():
	for child: LegsAction in get_descendants.player_states_by_type(legs_sm, "LegsAction"):
		print_.container("", "node.get_name() " + child.get_name())
		var action_data: LegActionData = _legs_action_data.get(child.get_name())
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
		child.anim_id = anim.anim_id
		child.anim_name = anim.anim_name
		child.DURATION = anim.duration
		
		child.action_name = action_data.action_name
		child.motion_type = action_data.motion_type

		assert(child.action_name and not child.action_name.is_empty(), "action_name problem for")
		assert(child.anim_id and not child.anim_id.is_empty(), " animation problem for action: " + child.action_name)
		

func states_priority_sort(a: String, b: String) -> bool:
	if _states[a].priority > _states[b].priority:
		return true
	else:
		return false
