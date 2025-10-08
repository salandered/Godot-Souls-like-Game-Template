extends RefCounted
class_name MovementPress

var forward: bool = false
var back: bool = false
var left: bool = false
var right: bool = false

func _to_string() -> String:
	var pressed = []
	if forward: pressed.append("W")
	if back: pressed.append("S")
	if left: pressed.append("A")
	if right: pressed.append("D")
	
	if pressed.is_empty():
		return "MovementPress: none"
	return "MovementPress: " + ", ".join(pressed)
