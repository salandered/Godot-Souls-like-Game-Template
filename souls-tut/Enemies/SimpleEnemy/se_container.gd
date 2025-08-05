extends Node
class_name SEStatesContainer


var me: SECharacter

var node_to_state_data: Dictionary = { # { Node name : StateData }
	"Idle": StateData.new(SEState.idle, SEA.idle),
	"Pursuit": StateData.new(SEState.pursuit, SEA.run),
	"Orbit": StateData.new(SEState.orbit, SEA.strafe_L),
	"Death": StateData.new(SEState.death, SEA.death),
	"Backtrack": StateData.new(SEState.backtrack, SEA.run),
	"Attack": StateData.new(SEState.attack, SEA.attack_1),
}


var states: Dictionary # { String : BaseSEState }

func _get_state_descendants(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BaseSEState:
			descendants.append(child)
		descendants.append_array(_get_state_descendants(child))
	return descendants
	
func accept_states():
	for state: BaseSEState in _get_state_descendants(self):
		var state_data: StateData = node_to_state_data.get(state.get_name())
		assert(state_data, "StateData for " + state.get_name() + " not found")

		state.state_name = state_data.state_name
		state.animation = state_data.animation_name

		states[state.state_name] = state
		
		# TODO: why assigning common things like animator for EACH state and not to _base one
		state.animator = me.animator
		state.me = me
		state.player = me.player
		state.spawn_point = me.spawn_point
		state.right_weapon = me.right_weapon
		state.resources = me.resources
		state.container = self
		# state.animation = state_anims[state.state_name]
		assert(state.state_name and not state.state_name.is_empty(), " state name missing on one of the states " + str(state))
		assert(state.animation and not state.animation.is_empty(), " animation problem for state: " + state.state_name)
		# assert(state.backend_animation and not state.backend_animation.is_empty(), " backend_animation problem for state: " + state.state_name)


func states_priority_sort(a: String, b: String):
	if states[a].priority > states[b].priority:
		return true
	else:
		return false


func get_state_by_name(state_name: String) -> BasePlayerState:
	assert(states.has(state_name), "states dict doesn't have " + state_name)
	return states[state_name]
