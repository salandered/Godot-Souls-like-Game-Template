extends RefCounted

class_name InputInternal

var forward_input := 0.0
var orbit_input := 0.0

func update():
	forward_input = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	orbit_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# print(forward_input)
	# print(orbit_input)

func get_forward() -> float:
	return forward_input

func get_orbiting() -> float:
	return orbit_input
