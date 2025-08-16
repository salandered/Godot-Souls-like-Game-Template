extends Node
class_name ActionUtils


var enter_action_time: float

# TIME MANAGEMENT
func mark_enter_action() -> void:
	enter_action_time = Time.get_unix_time_from_system()

func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_action_time


func works_longer_than(time: float) -> bool:
	if time == -1:
		return __reject()
	if get_progress() >= time:
		return true
	return false


func works_less_than(time: float) -> bool:
	if time == -1:
		return __reject()
	if get_progress() < time:
		return true
	return false


func works_between(start: float, finish: float) -> bool:
	if start == -1 or finish == -1:
		return __reject()
	var progress = get_progress()
	if progress >= start and progress <= finish:
		return true
	return false

# END TIME MANAGEMENT


func __reject() -> bool:
	print_.prefix("oooo TM oooo ", "time manage rejected -1", 5)
	return false
