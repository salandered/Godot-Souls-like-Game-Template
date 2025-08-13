extends Node
class_name PlayerStatesContainer

## Torso SM is the main one, and torso states are responsible for the overall transition logic of your character. 

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

var states: Dictionary # { string : State }, where string is State heirs name

func _get_state_descendants(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BasePlayerState:
			descendants.append(child)
		descendants.append_array(_get_state_descendants(child))
	return descendants
	
func accept_states():
	for state: BasePlayerState in _get_state_descendants(self):
		states[state.state_name] = state
		state.player = player
		state.full_body_animator = full_body_animator
		state.legs_animator = legs_animator
		state.torso_animator = torso_animator
		state.animation_settings = animation_settings
		state.skeleton = skeleton
		state.resources = resources
		state.left_wrist = left_wrist
		state.combat = combat
		state.states_data_repo = states_data_repo
		state.container = self
		state.DURATION = states_data_repo.get_duration(state.backend_animation)
		state.area_awareness = area_awareness
		state.legs_manager = legs_manager
		state.assign_combos()

		assert(state.priority and state.priority >= 0, " priority problem for state: " + state.state_name)
		assert(state.animation and not state.animation.is_empty(), " animation problem for state: " + state.state_name)
		assert(state.backend_animation and not state.backend_animation.is_empty(), " backend_animation problem for state: " + state.state_name)


func states_priority_sort(a: String, b: String):
	if states[a].priority > states[b].priority:
		return true
	else:
		return false


func get_state_by_name(state_name: String) -> BasePlayerState:
	assert(states.has(state_name), "states dict doesn't have " + state_name)
	return states[state_name]
