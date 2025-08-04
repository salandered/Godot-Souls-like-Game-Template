extends Node
class_name SEStatesContainer


var me: CharacterBody3D

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
		states[state.state_name] = state
		state.animator = me.animator
		state.me = me
		state.player = me.player
		state.spawn_point = me.spawn_point
		state.right_weapon = me.right_weapon
		state.resources = me.resources
		state.container = self

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
