extends Node
class_name PlayerStatesContainer


@export var player: Princess
@export var animation_settings: AnimationPlayer
@export var skeleton: Skeleton3D
@export var resources: HumanoidResources
@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var states_data_repo: StatesDataRepository
@export var legs_manager: LegsManager
@export var left_wrist: BoneAttachment3D

@export_group("skeleton_modifiers")
@export var full_body_animator: SimpleAnimator_
@export var legs_animator: SimpleAnimator_
@export var torso_animator: SimpleAnimator_


# @onready var legs: PlayerStatesContainer = %Legs # type?
# @export var default_bahavior: Node # Jog State?

#@export var anim_source: AnimationPlayer
#@export var torso_anim_settings: AnimationPlayer
# @onready var simple_torso: SkeletonModifierMeta = %TorsoSimple
# @onready var loc_torso: SkeletonModifierMeta = %TorsoLoc


var node_to_state_data: Dictionary = { # { Node name : SEStateData }
	# fight
	"Withdraw": PlayerStateData.new(PlayerState.withdraw, A.withdraw, ),
	"ShieldThrow": PlayerStateData.new(PlayerState.shield_throw, A.shield_throw),
	"ShieldThrowReload": PlayerStateData.new(PlayerState.shield_throw_reload, A.shield_throw_reload),
	"Longsword1": PlayerStateData.new(PlayerState.longsword1, A.longsword1),
	"Longsword2": PlayerStateData.new(PlayerState.longsword2, A.longsword2),
	"Block": PlayerStateData.new(PlayerState.block, A.block, "", A.SET_full_body_torso),
	"BlockReaction": PlayerStateData.new(PlayerState.block_reaction, A.block_reaction),
	"Pushback": PlayerStateData.new(PlayerState.pushback, A.pushback),
	"Staggered": PlayerStateData.new(PlayerState.staggered, A.staggered),
	"Parry": PlayerStateData.new(PlayerState.parry, A.parry),
	"Parried": PlayerStateData.new(PlayerState.parried, A.parried),
	"Riposte": PlayerStateData.new(PlayerState.riposte, A.riposte),
	# movement
	"Idle": PlayerStateData.new(PlayerState.idle, A.idle),
	"Walk": PlayerStateData.new(PlayerState.walk, A.walk, "walk-param", ),
	"Run": PlayerStateData.new(PlayerState.run, A.run),
	"Strafe": PlayerStateData.new(PlayerState.strafe, A.strafe_R),
	"Sprint": PlayerStateData.new(PlayerState.sprint, A.sprint),
	"JumpRun": PlayerStateData.new(PlayerState.jump_run, A.jump_sprint),
	"JumpSprint": PlayerStateData.new(PlayerState.jump_sprint, A.jump_sprint),
	"Midair": PlayerStateData.new(PlayerState.midair, A.midair),
	"LandingRun": PlayerStateData.new(PlayerState.landing_run, A.landing_run),
	"LandingSprint": PlayerStateData.new(PlayerState.landing_sprint, A.landing_sprint),
	"Roll": PlayerStateData.new(PlayerState.roll, A.roll),
	"Death": PlayerStateData.new(PlayerState.death, A.death),
}


var states: Dictionary # { string : State }, where string is State heirs name

func _get_state_descendants(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BasePlayerState:
			descendants.append(child)
		descendants.append_array(_get_state_descendants(child))
	return descendants
	
func accept_states():
	for node: BasePlayerState in _get_state_descendants(self):
		print("node.get_name() ", node.get_name())
		var state_data: PlayerStateData = node_to_state_data.get(node.get_name())
		assert(state_data, "PlayerStateData for " + node.get_name() + " not found")

		print("state_data.state_name ", state_data.state_name)

		states[state_data.state_name] = node

		node.state_name = state_data.state_name
		node.animation = state_data.animation_name
		node.backend_animation = state_data.backend_animation_name
		node.animator_set = state_data.animator_set
		
		node.player = player
		node.full_body_animator = full_body_animator
		node.legs_animator = legs_animator
		node.torso_animator = torso_animator
		node.animation_settings = animation_settings
		node.skeleton = skeleton
		node.resources = resources
		node.left_wrist = left_wrist
		node.combat = combat
		node.states_data_repo = states_data_repo
		node.container = self
		node.DURATION = states_data_repo.get_duration(state_data.backend_animation_name)
		node.area_awareness = area_awareness
		node.legs_manager = legs_manager
		node.assign_combos()

		assert(node.priority and node.priority >= 0, " priority problem for state: " + node.state_name)
		assert(node.animation and not node.animation.is_empty(), " animation problem for state: " + node.state_name)
		assert(node.backend_animation and not node.backend_animation.is_empty(), " backend_animation problem for state: " + node.state_name)
		assert(node.animator_set and not node.animator_set.is_empty(), " animator_set problem for state: " + node.state_name)


func states_priority_sort(a: String, b: String) -> bool:
	if states[a].priority > states[b].priority:
		return true
	else:
		return false


func get_state_by_name(state_name: String) -> BasePlayerState:
	assert(states.has(state_name), "states dict doesn't have " + state_name)
	return states[state_name]
