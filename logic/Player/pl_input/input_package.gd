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
class MovementPress:
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


var move_press: MovementPress = MovementPress.new()


class ReverseData:
	var is_reversed: bool = false
	var type: String = ""
	## time between presses which leaded to prev and target direction
	## if they overlapped, then 0.
	## is sequential, then <= SEQUENTIAL_PRESS_THRESHOLD
	var time_delta: float
	var prev_dir: Vector2 = Vector2.ZERO
	var target_dir: Vector2 = Vector2.ZERO
	
	## should be created only via this method
	func initialise(prev_dir_, target_dir_, type_, time_delta_):
		is_reversed = true
		type = type_
		time_delta = time_delta_
		prev_dir = prev_dir_
		target_dir = target_dir_

	func is_reversed_forward() -> bool:
		return type == "forward"

	func is_reversed_strafe() -> bool:
		return type == "strafe"

	func reset():
		is_reversed = false
		type = ""
		prev_dir = Vector2.ZERO
		target_dir = Vector2.ZERO
		
	func _to_string() -> String:
		if not is_reversed:
			return "ReverseData: none"
		
		var prev_name = _vector_to_direction_name(prev_dir)
		var target_name = _vector_to_direction_name(target_dir)
		return "ReverseData: %s reversal (%s -> %s)" % [type, prev_name, target_name]

	func _vector_to_direction_name(dir: Vector2) -> String:
		if dir == Vector2(0, -1):
			return "forward"
		elif dir == Vector2(0, 1):
			return "back"
		elif dir == Vector2(-1, 0):
			return "left"
		elif dir == Vector2(1, 0):
			return "right"
		else:
			return "unknown"

var reverse_data: ReverseData = ReverseData.new()


func _to_string() -> String:
	var parts = []
	parts.append(str(move_press))
	parts.append("input_dir: %s" % input_direction)
	if not actions.is_empty():
		parts.append("actions: %s" % ", ".join(actions))
	parts.append(str(reverse_data))
	
	return "InputPackage(%s)" % ", ".join(parts)
