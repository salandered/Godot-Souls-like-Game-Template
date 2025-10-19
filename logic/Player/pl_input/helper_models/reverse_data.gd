extends RefCounted
class_name ReverseData


enum ReverseType {
		VERTICAL,
		HORIZONTAL,
		NONE
	}

var _is_reversed: bool = false
var type: ReverseType = ReverseType.NONE
## time between presses which leaded to prev and target direction
## if they overlapped, then 0.
## is sequential, then <= SEQUENTIAL_PRESS_THRESHOLD
var time_delta: float
var prev_dir: Vector2
var target_dir: Vector2
## was any other directional key pressed during the reversal?
var other_keys_was_pressed: bool = false


## should be created only via this method
func initialise(prev_dir_, target_dir_, type_: ReverseType, time_delta_, other_keys_was_pressed_: bool = false) -> void:
	_is_reversed = true
	type = type_
	time_delta = time_delta_
	prev_dir = prev_dir_
	target_dir = target_dir_
	other_keys_was_pressed = other_keys_was_pressed_


func is_reversed() -> bool:
	return _is_reversed

func is_pure_reversed() -> bool:
	return _is_reversed and not other_keys_was_pressed

func is_reversed_forward() -> bool:
	return type == ReverseType.VERTICAL

func is_reversed_strafe() -> bool:
	return type == ReverseType.HORIZONTAL

func reset():
	_is_reversed = false
	type = ReverseType.NONE
	prev_dir = Vector2.ZERO
	target_dir = Vector2.ZERO
	
func _to_string() -> String:
	if not _is_reversed:
		return "ReverseData: none"
	
	var prev_name = _vector_to_direction_name(prev_dir)
	var target_name = _vector_to_direction_name(target_dir)
	return "ReverseData: %s reversal (%s -> %s) [%.4f, %s]" \
		% [type, prev_name, target_name, time_delta, other_keys_was_pressed]

func _vector_to_direction_name(dir: Vector2) -> String:
	# todo: some vector enum
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