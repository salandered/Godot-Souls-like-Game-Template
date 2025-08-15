extends Node
class_name LegsManager


#@export var combat: HumanoidCombat
#@export var area_awareness: AreaAwareness
@export var player: Princess
@export var anim_settings: AnimationPlayer
# @onready var torso: PlayerStatesContainer = %Torso
#@export var legs_behavior
#@export var legs_actions


# The more suited approach will be inherit BasePlayerState once more to define LegsState 
# then those heirs will register themselves here on_enter state.
# This way we could escape the need to manually call update() here.
# But I wanted a fast makeshift patch to work
@export var model: PlayerModel
# @export var legs_states : Array[BasePlayerState]
var current_legs_state: BasePlayerState


func accept_behaviors():
	for child in get_children():
		if child is LegsBehaviorOld:
			child.model = model
			child.states_container = model.states_container
			child.legs_manager = self
			child.current_legs_state = current_legs_state
