@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")
extends Node
class_name SEStatesContainer

var me: SECharacter

var _node_to_state_data: Dictionary = {
	"Idle": SEStateData.new(SEState.idle, SEA.idle, 1, 0.4, -1),
	"Pursuit": SEStateData.new(SEState.pursuit, SEA.run, 7, 0.5, 9),
	"Follow": SEStateData.new(SEState.follow, SEA.walk, 5, 0.5, 7),
	"Midair": SEStateData.new(SEState.midair, SEA.midair, -1, -1, -1),
	"Orbit": SEStateData.new(SEState.orbit, SEA.strafe_L, 2, 0.5, 5),
	"Death": SEStateData.new(SEState.death, SEA.death, -1, -1, -1),
	"Backtrack": SEStateData.new(SEState.backtrack, SEA.run, -1, 1, 15),
	"Attack": SEStateData.new(SEState.attack, SEA.attack_1, 8, -1, -1),
}


func state_by_name(state_name: String) -> BaseSEState:
	assert(_states.has(state_name), "_states dict doesn't have " + state_name)
	return _states[state_name]


var _states: Dictionary # { String : BaseSEState }

func accept_states():
	for node: BaseSEState in get_descendants.base_se_states(self):
		print_.container("", "node.get_name() " + node.get_name())
		var state_data: SEStateData = _node_to_state_data.get(node.get_name())
		assert(state_data, "SEStateData for " + node.get_name() + " not found")

		print_.container("", "state_data.state_name " + state_data.state_name)

		_states[state_data.state_name] = node
		
		# specific
		node.state_name = state_data.state_name
		node.anim_id = state_data.animation_name
		node.global_commitment = state_data.global_commitment
		node.iteration_commitment = state_data.iteration_commitment
		node.fatigue = state_data.fatigue

		# common
		node.animator = me.animator
		node.me = me
		node.spawn_point = me.spawn_point
		node.combat = me.combat
		node.feelings = me.feelings
		node.traits = me.traits_container
		node.container = self

		assert(node.state_name and not node.state_name.is_empty(), " state name missing on one of the _states " + str(node))
		assert(node.anim_id and not node.anim_id.is_empty(), " animation problem for state: " + node.state_name)
		assert(node.global_commitment, " global_commitment problem for state: " + node.state_name)
		assert(node.iteration_commitment, " iteration_commitment problem for state: " + node.state_name)
		assert(node.fatigue, " fatigue problem for state: " + node.state_name)
