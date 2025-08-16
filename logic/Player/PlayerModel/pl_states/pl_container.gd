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
	# "Withdraw": PSData.new(PS.withdraw, 15),
	# "ShieldThrow": PSData.new(PS.shield_throw, 16),
	# "ShieldThrowReload": PSData.new(PS.shield_throw_reload, 17),
	# "Longsword1": PSData.new(PS.longsword1, 15),
	# "Longsword2": PSData.new(PS.longsword2, 15),
	# "Block": PSData.new(PS.block, A.block, "", 21),
	# "BlockReaction": PSData.new(PS.block_reaction, 90),
	# "Pushback": PSData.new(PS.pushback, 101),
	# "Staggered": PSData.new(PS.staggered, 100),
	# "Parry": PSData.new(PS.parry, 20),
	# "Parried": PSData.new(PS.parried, 100),
	# "Riposte": PSData.new(PS.riposte, 25),
	# "Idle": PSData.new(PS.idle, 1, "IdleLegs"),
	# "Walk": PSData.new(PS.walk, 2),
	"Run": PSData.new(PS.run, 2, "leg_run_behavior"),
	# "Strafe": PSData.new(PS.strafe, 3),
	# "Sprint": PSData.new(PS.sprint, 3, "leg_sprint_behavior"),
	# "JumpRun": PSData.new(PS.jump_run, 10),
	# "JumpSprint": PSData.new(PS.jump_sprint, 10),
	# "Midair": PSData.new(PS.midair, 10),
	# "LandingRun": PSData.new(PS.landing_run, 10),
	# "LandingSprint": PSData.new(PS.landing_sprint, 10),
	# "Roll": PSData.new(PS.roll, 20),
	# "Death": PSData.new(PS.death, 200),
}

var _player_action_data: Dictionary = { # { Node name : PlayerActionData }
	# fight
	# "Withdraw": PlayerActionData.new(PS.withdraw, A.withdraw, ),
	# "ShieldThrow": PlayerActionData.new(PS.shield_throw, A.shield_throw),
	# "ShieldThrowReload": PlayerActionData.new(PS.shield_throw_reload, A.shield_throw_reload),
	# "Longsword1": PlayerActionData.new(PS.longsword1, A.longsword1),
	# "Longsword2": PlayerActionData.new(PS.longsword2, A.longsword2),
	# "Block": PlayerActionData.new(PS.block, A.block, "", A.SET_full_body_torso),
	# "BlockReaction": PlayerActionData.new(PS.block_reaction, A.block_reaction),
	# "Pushback": PlayerActionData.new(PS.pushback, A.pushback),
	# "Staggered": PlayerActionData.new(PS.staggered, A.staggered),
	# "Parry": PlayerActionData.new(PS.parry, A.parry),
	# "Parried": PlayerActionData.new(PS.parried, A.parried),
	# "Riposte": PlayerActionData.new(PS.riposte, A.riposte),
	# movement
	"IdleAction": PlayerActionData.new(PS.action_idle, A.idle),
	# "Walk": PlayerActionData.new(PS.walk, A.walk, "walk-param", ),
	"RunAction": PlayerActionData.new(PS.action_run, A.run),
	# "Strafe": PlayerActionData.new(PS.strafe, A.strafe_R),
	"SprintAction": PlayerActionData.new(PS.action_sprint, A.sprint),
	# "JumpRun": PlayerActionData.new(PS.jump_run, A.jump_sprint),
	# "JumpSprint": PlayerActionData.new(PS.jump_sprint, A.jump_sprint),
	# "Midair": PlayerActionData.new(PS.midair, A.midair),
	# "LandingRun": PlayerActionData.new(PS.landing_run, A.landing_run),
	# "LandingSprint": PlayerActionData.new(PS.landing_sprint, A.landing_sprint),
	# "Roll": PlayerActionData.new(PS.roll, A.roll),
	# "Death": PlayerActionData.new(PS.death, A.death),
}


var _legs_behavior_data: Dictionary = {
	"RunLegs": LegBehaviorData.new("leg_run_behavior"),
	# "SprintLegs": LegBehaviorData.new("leg_sprint_behavior"),
	"DoubleLegs": LegBehaviorData.new("leg_double_behavior"),
}

var _legs_action_data: Dictionary = {
	"DoubleAction": LegActionData.new(PS.legs_action_double, "", LegsSM.MotionType.IDLE),
	"IdleAction": LegActionData.new(PS.legs_action_idle, A.idle, LegsSM.MotionType.IDLE),
	"RunAction": LegActionData.new(PS.legs_action_run, A.run, LegsSM.MotionType.CYCLE),
	# "SprintAction": LegActionData.new(PS.legs_action_sprint, A.sprint, LegsSM.MotionType.CYCLE),
}


var _states: Dictionary # { string : PlayerState }

var _player_actions: Dictionary # { string : PlayerAction }

var _legs_behaviors: Dictionary # { string : LegsBehavior }

var _leg_actions: Dictionary # { Node name : LegsAction }


func state_by_name(state_name: String) -> PlayerState:
	if not _states.has(state_name):
		print_.prefix("ERROR =PSContainer=", "state_by_name: " + state_name + " not found")
		return _states[PS.run]
	# assert(_states.has(state_name), "_states dict doesn't have " + state_name)
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
			continue

		print("state_data.state_name ", state_data.state_name)

		_states[state_data.state_name] = child

		child.state_name = state_data.state_name
		child.priority = state_data.priority
		
		# legs behaviors should be already accepted 
		child.legs_behavior = legs_behavior_by_name(state_data.legs_behavior_name)

		child.player = player
		child.resources = resources
		child.left_wrist = left_wrist
		child.combat = combat
		child.states_data_repo = states_data_repo
		child.container = self
		child.area_awareness = area_awareness
		child.legs_sm = legs_sm
		child.assign_combos()

		assert(child.state_name and not child.state_name.is_empty(), " state_name problem for state ")
		assert(child.priority and child.priority >= 0, " priority problem for state: " + child.state_name)


func accept_actions():
	for child: PlayerAction in _get_all_descendants(player_sm, "PlayerAction"):
		print("child.get_name() ", child.get_name())
		var action_data: PlayerActionData = _player_action_data.get(child.get_name())
		# assert(action_data, "PlayerActionData for " + child.get_name() + " not found")
		if not action_data:
			continue
		print("action_data.action_name ", action_data.action_name)

		_player_actions[action_data.action_name] = child

		child.action_name = action_data.action_name
		child.animation = action_data.animation_name
		child.backend_animation = action_data.backend_animation_name
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


func accept_legs_behaviors():
	for child: LegsBehavior in _get_all_descendants(legs_sm, "LegsBehavior"):
		print("node.get_name() ", child.get_name())
		var behavior_data: LegBehaviorData = _legs_behavior_data.get(child.get_name())
		if not behavior_data:
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
