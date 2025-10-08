extends Resource
class_name InputPackage

var input_direction: Vector2

# NOTE: for now actions contains player states like PS.run
var actions: Array[String]
var combat_actions: Array[String]

# Target
var target_lock_pressed: bool = false
var target_lock_long_pressed: bool = false

# Fancy camera
var forward_input := 0.0
var orbit_input := 0.0

# 

var move_press: MovementPress = MovementPress.new()

var reverse_data: ReverseData = ReverseData.new()


func _to_string() -> String:
	var parts = []
	parts.append(str(move_press))
	parts.append("input_dir: %s" % input_direction)
	if not actions.is_empty():
		parts.append("actions: %s" % ", ".join(actions))
	parts.append(str(reverse_data))
	
	return "InputPackage(%s)" % ", ".join(parts)
