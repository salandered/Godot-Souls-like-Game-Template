extends RefCounted
class_name ReverseData

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