extends Node
## technically speaking, this is a SM
## The states of the SM are the exact same states our main SM uses.
class_name LegsBehaviour


var model: PlayerModel
var states_container: HumanoidStates
var legs_manager: Legs
var current_legs_state: BasePlayerState


func update(input: InputPackage, delta: float):
	transition_legs_state(input, delta)
	current_legs_state._update(input, delta)


## transition logic now returns nothing. The class expects it to change the current move before updating
func transition_legs_state(_input, _delta):
	pass


func change_state(next_state: String):
	current_legs_state = states_container.get_state_by_name(next_state)
	legs_manager.current_legs_state = current_legs_state
	model.animator.update_legs_animation()
