extends RefCounted

class_name CustomDelta


# TODO: Unix time in millisecond, needs a better time calculation
var last_process_time: float # seconds unix from system
var delta: float # seconds
var now: float # seconds unix from system


func _init(last_process_time_: float = 0.0, delta_: float = 0.0, now_: float = 0.0) -> void:
	self.last_process_time = last_process_time_
	self.delta = delta_
	self.now = now_


func update() -> void:
	now = _get_curr_time()
	delta = now - last_process_time
	last_process_time = now


func update_last_process_time() -> void:
	last_process_time = _get_curr_time()


func _get_curr_time() -> float:
	return Time.get_unix_time_from_system()
