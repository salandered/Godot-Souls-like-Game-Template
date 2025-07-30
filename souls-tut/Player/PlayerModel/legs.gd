extends Node
class_name Legs


# The more suited approach will be inherit BasePlayerState once more to define LegsState 
# then those heirs will register themselves here on_enter state.
# This way we could escape the need to manually call update() here.
# But I wanted a fast makeshift patch to work
@export var model: PlayerModel
#@export var legs_states : Array[BasePlayerState]
var current_legs_state: BasePlayerState


func accept_behaviours():
	for child in get_children():
		if child is LegsBehaviour:
			child.model = model
			child.states_container = model.states_container
			child.legs_manager = self
			child.current_legs_state = current_legs_state
