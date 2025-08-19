extends Node
class_name PlayerStatesContainer


# -- set by model
var player: Princess

# @export var skeleton: Skeleton3D
@export var resources: HumanoidResources
@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var states_data_repo: StatesDataRepository
@export var left_wrist: BoneAttachment3D


@export_group("SM")
@export var legs_sm: LegsSM
@export var player_sm: PlayerSM

@export_group("animation")
# @export var animation_settings: AnimationPlayer
@export var full_body_animator: SimpleAnimator_
@export var legs_animator: SimpleAnimator_
@export var torso_animator: SimpleAnimator_
#@export var anim_source: AnimationPlayer
#@export var torso_anim_settings: AnimationPlayer
# @export var legs_anim_settings: AnimationPlayer

# @export var default_bahavior: Node # Run State?

var _state_data: Dictionary = { # { Node name : PSData }
	# move
	# "Idle": PSData.new(PS.idle, 1, LS.legs_idle_behavior),
	# "Walk": PSData.new(PS.walk, 2),
	"Run": PSData.new(PS.run, 2, LS.legs_run_behavior),
	"Strafe": PSData.new(PS.strafe, 3, LS.legs_double_behavior),
	"Sprint": PSData.new(PS.sprint, 3, LS.legs_sprint_behavior),
	"JumpRun": PSData.new(PS.jump_run, 10, LS.legs_double_behavior),
	"JumpSprint": PSData.new(PS.jump_sprint, 10, LS.legs_double_behavior),
	"Midair": PSData.new(PS.midair, 10, LS.legs_double_behavior),
	"LandingRun": PSData.new(PS.landing_run, 10, LS.legs_double_behavior),
	"LandingSprint": PSData.new(PS.landing_sprint, 10, LS.legs_double_behavior),
	"Roll": PSData.new(PS.roll, 20, LS.legs_double_behavior),
	"Death": PSData.new(PS.death, 200, LS.legs_double_behavior),
	# fight
	"Longsword1": PSData.new(PS.longsword_1, 15, LS.legs_double_behavior),
	"Longsword2": PSData.new(PS.longsword_2, 15, LS.legs_double_behavior),
	"Block": PSData.new(PS.block, 21, LS.legs_run_behavior),
	"BlockReaction": PSData.new(PS.block_reaction, 90, LS.legs_double_behavior),
	"Withdraw": PSData.new(PS.withdraw, 15, LS.legs_double_behavior),
	"ShieldThrow": PSData.new(PS.shield_throw, 16, LS.legs_double_behavior),
	"ShieldThrowReload": PSData.new(PS.shield_throw_reload, 17, LS.legs_double_behavior),
	"Pushback": PSData.new(PS.pushback, 101, LS.legs_double_behavior),
	"Staggered": PSData.new(PS.staggered, 100, LS.legs_double_behavior),
	"Parry": PSData.new(PS.parry, 20, LS.legs_double_behavior),
	"Parried": PSData.new(PS.parried, 100, LS.legs_double_behavior),
	"Riposte": PSData.new(PS.riposte, 25, LS.legs_double_behavior),

}

var _player_action_data: Dictionary = { # { Node name : PlayerActionData }

	# move
	# "DummyIdleAction": PlayerActionData.new(PS.idle, PS.dummy_action_idle, A.idle, ),
	"IdleRunAction": PlayerActionData.new(PS.run, PS.action_idle, A.combat_idle, ),
	# "Walk": PlayerActionData.new(PS.walk,PS.action_block, A.walk, "walk-param", , ),
	"RunAction": PlayerActionData.new(PS.run, PS.action_run, A.combat_run, "", 0.4),
	"StrafeAction": PlayerActionData.new(PS.strafe, PS.action_block, A.strafe_R, ),
	# "IdleSprintAction": PlayerActionData.new(PS.run, PS.action_sprint_idle, A.idle, ),
	"SprintAction": PlayerActionData.new(PS.sprint, PS.action_sprint, A.combat_sprint, ),
	"JumpRunAction": PlayerActionData.new(PS.jump_run, PS.action_jump_run, A.jump_run, ),
	"JumpSprintAction": PlayerActionData.new(PS.jump_sprint, PS.action_jump_sprint, A.jump_sprint, ),
	"MidairAction": PlayerActionData.new(PS.midair, PS.action_midair, A.midair, ),
	"LandingRunAction": PlayerActionData.new(PS.landing_run, PS.action_landing_run, A.landing_run, ),
	"LandingSprintAction": PlayerActionData.new(PS.landing_sprint, PS.action_landing_sprint, A.landing_sprint, ),
	"RollAction": PlayerActionData.new(PS.roll, PS.action_roll, A.roll, ),
	"DeathAction": PlayerActionData.new(PS.death, PS.action_death, A.death, ),
	# fight
	"Longsword1Action": PlayerActionData.new(PS.longsword_1, PS.action_longsword_1, A.longsword_1, ),
	"Longsword2Action": PlayerActionData.new(PS.longsword_2, PS.action_longsword_2, A.longsword_2, ),
	"BlockAction": PlayerActionData.new(PS.block, PS.action_block, A.block_forward, ),
	"BlockReactionAction": PlayerActionData.new(PS.block_reaction, PS.action_block_reaction, A.block_reaction, ),
	"WithdrawAction": PlayerActionData.new(PS.withdraw, PS.action_withdraw, A.withdraw, ),
	"ShieldThrowAction": PlayerActionData.new(PS.shield_throw, PS.action_shield_throw, A.shield_throw, ),
	"ShieldThrowReloadAction": PlayerActionData.new(PS.shield_throw_reload, PS.action_shield_throw_reload, A.shield_throw_reload, ),
	"PushbackAction": PlayerActionData.new(PS.pushback, PS.action_pushback, A.pushback, ),
	"StaggeredAction": PlayerActionData.new(PS.staggered, PS.action_staggered, A.staggered, ),
	"ParryAction": PlayerActionData.new(PS.parry, PS.action_parry, A.parry, ),
	"ParriedAction": PlayerActionData.new(PS.parried, PS.action_parried, A.parried, ),
	"RiposteAction": PlayerActionData.new(PS.riposte, PS.action_riposte, A.riposte_attack, ),
}

func _get_actions_by_state(state: String) -> Array[PlayerActionData]:
	var result: Array[PlayerActionData] = []
	for node_ in _player_action_data.keys():
		var action_data: PlayerActionData = _player_action_data[node_]
		if action_data.state_name == state:
			result.append(action_data)
	return result


var _legs_behavior_data: Dictionary = {
	# "IdleLegs": LegBehaviorData.new(LS.legs_idle_behavior),
	"RunLegs": LegBehaviorData.new(LS.legs_run_behavior),
	"SprintLegs": LegBehaviorData.new(LS.legs_sprint_behavior),
	# "AirLegs": LegBehaviorData.new(LS.legs_air_behavior),
	"DoubleLegs": LegBehaviorData.new(LS.legs_double_behavior),
}

var _legs_action_data: Dictionary = {
	"IdleAction": LegActionData.new(LS.legs_action_idle, A.combat_idle, LegsSM.MotionType.IDLE),
	"RunAction": LegActionData.new(LS.legs_action_run, A.combat_run, LegsSM.MotionType.CYCLE),
	"SprintAction": LegActionData.new(LS.legs_action_sprint, A.combat_sprint, LegsSM.MotionType.CYCLE),
	"JumpStartAction": LegActionData.new(LS.legs_action_jump_start, A.jump_run, LegsSM.MotionType.IDLE),
	# "AirAction": LegActionData.new(LS.legs_action_air, A.midair, LegsSM.MotionType.IDLE),
	"LandAction": LegActionData.new(LS.legs_action_land, A.landing_run, LegsSM.MotionType.IDLE),
	"DoubleAction": LegActionData.new(LS.legs_action_double, "-", LegsSM.MotionType.IDLE),
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


func accept_player_states():
	for child: PlayerState in _get_all_descendants(player_sm, "PlayerState"):
		print("child.get_name() ", child.get_name())
		var state_data: PSData = _state_data.get(child.get_name())
		# assert(state_data, "PSData for " + child.get_name() + " not found")
		if not state_data:
			push_error("No state data found for: " + child.get_name())
			continue

		print("state_data.state_name ", state_data.state_name)

		_states[state_data.state_name] = child

		child.state_name = state_data.state_name
		child.priority = state_data.priority
		
		# legs behaviors should be accepted before
		child.legs_behavior = legs_behavior_by_name(state_data.legs_behavior_name)
		
		# TODO: rewrite using just dict data
		# var actions := _get_state_descendants(child)
		var actions := _get_actions_by_state(state_data.state_name)
		assert(actions.size() > 0, "No actions found for state: " + child.state_name)
		child.default_action_name = actions[0].action_name
		
		
		child.player = player
		child.resources = resources
		child.left_wrist = left_wrist
		child.combat = combat
		child.states_data_repo = states_data_repo
		child.container = self
		child.area_awareness = area_awareness
		child.player_sm = player_sm
		child.legs_sm = legs_sm
		child.assign_combos()

		assert(child.legs_behavior, " legs_behavior problem for state: " + child.state_name)
		assert(child.state_name and not child.state_name.is_empty(), " state_name problem for state ")
		assert(child.default_action_name and not child.default_action_name.is_empty(), " default_action_name problem for state " + child.state_name)
		assert(child.priority and child.priority >= 0, " priority problem for state: " + child.state_name)

	print("===========  Accepted states ===========")
	print(_states)
	print()

func accept_player_actions():
	for child: PlayerAction in _get_all_descendants(player_sm, "PlayerAction"):
		print("child.get_name() ", child.get_name())
		var action_data: PlayerActionData = _player_action_data.get(child.get_name())
		# assert(action_data, "PlayerActionData for " + child.get_name() + " not found")
		if not action_data:
			push_error("No action data found for: " + child.get_name())
			continue
		print("action_data.action_name ", action_data.action_name)

		_player_actions[action_data.action_name] = child

		child.action_name = action_data.action_name
		child.animation = action_data.animation_name
		child.backend_animation = action_data.backend_animation_name
		child.blend_time = action_data.blend_time
		# node.animator_set = action_data.animator_set
		
		child.player = player
		# node.full_body_animator = full_body_animator
		child.legs_animator = legs_animator
		child.torso_animator = torso_animator
		# node.animation_settings = animation_settings
		child.combat = combat
		child.states_data_repo = states_data_repo
		child.DURATION = states_data_repo.get_duration(action_data.backend_animation_name)

		assert(child.action_name and not child.action_name.is_empty(), " animation problem for action_name")
		assert(child.animation and not child.animation.is_empty(), " animation problem for action: " + child.action_name)
		assert(child.backend_animation and not child.backend_animation.is_empty(), " backend_animation problem for action: " + child.action_name)
		# assert(node.animator_set and not node.animator_set.is_empty(), " animator_set problem for action: " + node.action_name)
	print("===========  Accepted actions ===========")
	print(_player_actions)
	print()

func accept_legs_behaviors():
	for child: LegsBehavior in _get_all_descendants(legs_sm, "LegsBehavior"):
		print("node.get_name() ", child.get_name())
		var behavior_data: LegBehaviorData = _legs_behavior_data.get(child.get_name())
		if not behavior_data:
			push_error("No behavior data found for: " + child.get_name())
			continue
		print("behavior_data.behavior_name ", behavior_data.behavior_name)
		_legs_behaviors[behavior_data.behavior_name] = child

		child.behavior_name = behavior_data.behavior_name

		child.player = player
		child.combat = combat
		child.legs_sm = legs_sm
		child.container = self
		child.area_awareness = area_awareness

		assert(child.behavior_name and not child.behavior_name.is_empty(), " animation problem for behavior")


func accept_legs_actions():
	for child: LegsAction in _get_all_descendants(legs_sm, "LegsAction"):
		print("node.get_name() ", child.get_name())
		var action_data: LegActionData = _legs_action_data.get(child.get_name())
		if not action_data:
			push_error("No action data found for: " + child.get_name())
			continue
		print("action_data.action_name ", action_data.action_name)
		_leg_actions[action_data.action_name] = child

		child.action_name = action_data.action_name
		child.animation = action_data.animation_name

		child.legs_animator = legs_animator
		child.player = player
		child.combat = combat
		child.legs_sm = legs_sm
		# child.legs_anim_settings = legs_anim_settings

		assert(child.action_name and not child.action_name.is_empty(), " animation problem for action_name")
		assert(child.animation and not child.animation.is_empty(), " animation problem for action: " + child.action_name)
		

func states_priority_sort(a: String, b: String) -> bool:
	if _states[a].priority > _states[b].priority:
		return true
	else:
		return false


func _get_all_descendants(node: Node, target_type: StringName) -> Array:
	var descendants: Array = []
	
	for child in node.get_children():
		match target_type:
			"PlayerState":
				if child is PlayerState: descendants.append(child)
			"PlayerAction":
				if child is PlayerAction: descendants.append(child)
			"LegsBehavior":
				if child is LegsBehavior: descendants.append(child)
			"LegsAction":
				if child is LegsAction: descendants.append(child)
			
		descendants.append_array(_get_all_descendants(child, target_type))

	return descendants

func _get_state_descendants(node: Node) -> Array:
	var descendants: Array = []
	
	for child in node.get_children():
		if child is PlayerAction:
			descendants.append(child)

	return descendants
