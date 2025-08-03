extends Node
## Small SM
## The states of the SM are the exact same states our main SM uses.
## Two core methods, transition logic and update logic. 
class_name LegsBehaviour


var model: PlayerModel
var states_container: HumanoidStates
var legs_manager: LegsManager

# legs state is just ordinary BasePlayerState.
var current_legs_state: BasePlayerState


func update(input: InputPackage, delta: float):
	transition_legs_state(input, delta)
	current_legs_state._update(input, delta)


## Implemented in LegsBehaviour heirs. Calls change_state()
func transition_legs_state(_input, _delta):
	pass

## used in LegsBehaviour heirs
func change_state(next_state: String):
	current_legs_state = states_container.get_state_by_name(next_state)
	# why not using LegsBehaviour where state already stored?
	legs_manager.current_legs_state = current_legs_state
	model.animator.update_legs_animation()