extends Node
class_name SEStatesContainer

var me: SECharacter

var node_to_state_data: Dictionary = { # { Node name : StateData }
	"Idle": StateData.new(SEState.idle, SEA.idle, "", 1, 0.4, -1),
	"Pursuit": StateData.new(SEState.pursuit, SEA.run, "", 7, 0.5, 9),
	"Follow": StateData.new(SEState.follow, SEA.walk, "", 5, 0.5, 7),
	"Midair": StateData.new(SEState.midair, SEA.midair, "", -1, -1, -1),
	"Orbit": StateData.new(SEState.orbit, SEA.strafe_L, "", 2, 0.5, 5),
	"Death": StateData.new(SEState.death, SEA.death, "", -1, -1, -1),
	"Backtrack": StateData.new(SEState.backtrack, SEA.run, "", -1, 1, 15),
	"Attack": StateData.new(SEState.attack, SEA.attack_1, "", 8, -1, -1),
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
	for node: BaseSEState in _get_state_descendants(self):
		print("node.get_name() ", node.get_name())
		var state_data: StateData = node_to_state_data.get(node.get_name())
		assert(state_data, "StateData for " + node.get_name() + " not found")

		print("state_data.state_name ", state_data.state_name)

		states[state_data.state_name] = node
		
		# TODO: why assigning common things like animator for EACH state and not to _base one
		
		node.state_name = state_data.state_name
		node.animation = state_data.animation_name
		node.backend_animation = SEA.to_backend_lazy(state_data.animation_name)
		node.global_commitment = state_data.global_commitment
		node.iteration_commitment = state_data.iteration_commitment
		node.fatigue = state_data.fatigue

		node.animator = me.animator
		node.me = me
		node.player = me.player
		node.spawn_point = me.spawn_point
		node.right_weapon = me.right_weapon
		node.resources = me.resources
		node.traits = me.traits_container
		node.container = self
		# state.animation = state_anims[state.state_name]
		assert(node.state_name and not node.state_name.is_empty(), " state name missing on one of the states " + str(node))
		assert(node.animation and not node.animation.is_empty(), " animation problem for state: " + node.state_name)
		# assert(state.backend_animation and not state.backend_animation.is_empty(), " backend_animation problem for state: " + state.state_name)
		assert(node.global_commitment, " global_commitment problem for state: " + node.state_name)
		assert(node.iteration_commitment, " iteration_commitment problem for state: " + node.state_name)
		assert(node.fatigue, " fatigue problem for state: " + node.state_name)

# func states_priority_sort(a: String, b: String):
# 	if states[a].priority > states[b].priority:
# 		return true
# 	else:
# 		return false


# func get_state_by_name(state_name: String) -> BasePlayerState:
# 	assert(states.has(state_name), "states dict doesn't have " + state_name)
# 	return states[state_name]
