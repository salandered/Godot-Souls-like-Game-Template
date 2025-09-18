extends Node
class_name SEStatesContainer

var me: SECharacter

var node_to_state_data: Dictionary = { # { Node name : SEStateData }
	"Idle": SEStateData.new(SEState.idle, SEA.idle, "", 1, 0.4, -1),
	"Pursuit": SEStateData.new(SEState.pursuit, SEA.run, "", 7, 0.5, 9),
	"Follow": SEStateData.new(SEState.follow, SEA.walk, "", 5, 0.5, 7),
	"Midair": SEStateData.new(SEState.midair, SEA.midair, "", -1, -1, -1),
	"Orbit": SEStateData.new(SEState.orbit, SEA.strafe_L, "", 2, 0.5, 5),
	"Death": SEStateData.new(SEState.death, SEA.death, "", -1, -1, -1),
	"Backtrack": SEStateData.new(SEState.backtrack, SEA.run, "", -1, 1, 15),
	"Attack": SEStateData.new(SEState.attack, SEA.attack_1, "", 8, -1, -1),
}


var states: Dictionary # { String : BaseSEState }


func accept_states():
	for node: BaseSEState in get_descendants.base_se_states(self):
		print_.container("", "node.get_name() " + node.get_name())
		var state_data: SEStateData = node_to_state_data.get(node.get_name())
		assert(state_data, "SEStateData for " + node.get_name() + " not found")

		print_.container("", "state_data.state_name " + state_data.state_name)

		states[state_data.state_name] = node
		
		# TODO: why assigning common things like animator for EACH state and not to _base one
		
		node.state_name = state_data.state_name
		node.animation = state_data.animation_name
		node.backend_animation = state_data.backend_animation_name
		node.global_commitment = state_data.global_commitment
		node.iteration_commitment = state_data.iteration_commitment
		node.fatigue = state_data.fatigue

		node.animator = me.animator
		node.me = me
		node.player = me.player
		node.spawn_point = me.spawn_point
		node.right_weapon = me.right_weapon
		node.resources = me.feelings
		node.traits = me.traits_container
		node.container = self
		# state.animation = state_anims[state.state_name]
		assert(node.state_name and not node.state_name.is_empty(), " state name missing on one of the states " + str(node))
		assert(node.animation and not node.animation.is_empty(), " animation problem for state: " + node.state_name)
		# assert(state.backend_animation and not state.backend_animation.is_empty(), " backend_animation problem for state: " + state.state_name)
		assert(node.global_commitment, " global_commitment problem for state: " + node.state_name)
		assert(node.iteration_commitment, " iteration_commitment problem for state: " + node.state_name)
		assert(node.fatigue, " fatigue problem for state: " + node.state_name)


# func get_state_by_name(state_name: String) -> BasePlayerState:
# 	assert(states.has(state_name), "states dict doesn't have " + state_name)
# 	return states[state_name]
