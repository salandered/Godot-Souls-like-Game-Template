extends Node
class_name HumanoidStates


@export var player: CharacterBody3D
@export var animator: SplitBodyAnimator
@export var skeleton: Skeleton3D
@export var resources: HumanoidResources
@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var states_data_repo: StatesDataRepository
@export var legs: Legs
@export var left_wrist: BoneAttachment3D

var states: Dictionary # { string : State }, where string is State heirs name


func accept_states():
	for child in get_children():
		if child is BasePlayerState:
			states[child.state_name] = child
			child.player = player
			child.animator = animator
			child.skeleton = skeleton
			child.resources = resources
			child.left_wrist = left_wrist
			child.combat = combat
			child.states_data_repo = states_data_repo
			child.container = self
			child.DURATION = states_data_repo.get_duration(child.backend_animation)
			child.area_awareness = area_awareness
			child.legs = legs
			child.assign_combos()

			if child.priority <= 0:
				print_debug("Error for ", child.state_name)

			if child.animation.is_empty():
				print_debug("Error for ", child.state_name)

			if child.backend_animation.is_empty():
				print_debug("Error for ", child.state_name)


func states_priority_sort(a: String, b: String):
	if states[a].priority > states[b].priority:
		return true
	else:
		return false


func get_state_by_name(state_name: String) -> BasePlayerState:
	return states[state_name]
