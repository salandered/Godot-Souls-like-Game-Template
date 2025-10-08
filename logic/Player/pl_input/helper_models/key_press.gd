extends RefCounted
class_name KeyPress

var is_pressed: bool = false
var is_just_pressed: bool = false
var is_just_released: bool = false
var last_press_time: float = -999.0
var last_release_time: float = -999.0

func update(action: String, current_time: float) -> void:
	is_pressed = Input.is_action_pressed(action)
	is_just_pressed = Input.is_action_just_pressed(action)
	is_just_released = Input.is_action_just_released(action)

	if is_just_pressed:
		last_press_time = current_time
	
	if is_just_released:
		last_release_time = current_time

func get_time_since_press(current_time: float) -> float:
	if last_press_time < 0:
		return INF
	return current_time - last_press_time