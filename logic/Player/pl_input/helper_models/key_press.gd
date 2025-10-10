extends RefCounted
class_name KeyPress

var raw_action: String

var is_pressed: bool = false
var is_just_pressed: bool = false
var is_just_released: bool = false
var last_press_time: float = - Constants.BIG_MEANINGLESS_NUMBER
var last_release_time: float = - Constants.BIG_MEANINGLESS_NUMBER

func _init(raw_action_: String) -> void:
	self.raw_action = raw_action_

func update(current_time: float) -> void:
	is_pressed = Input.is_action_pressed(raw_action)
	is_just_pressed = Input.is_action_just_pressed(raw_action)
	is_just_released = Input.is_action_just_released(raw_action)

	if is_just_pressed:
		last_press_time = current_time
	
	if is_just_released:
		last_release_time = current_time


func get_time_since_press(current_time: float) -> float:
	if last_press_time < 0:
		return INF
	return current_time - last_press_time


func was_released_at_least_one() -> bool:
	return last_release_time > 0