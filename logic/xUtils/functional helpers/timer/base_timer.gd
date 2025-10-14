extends RefCounted
class_name BaseTimer

var duration: float
var timer: float = 0.0


## idempotent
# func initialise(...) -> void


## Returns true when timer expires
# func update(delta: float, ...) -> bool


# func reset() -> void

func is_complete() -> bool:
	return timer >= duration


func get_elapsed() -> float:
	return timer

func get_remaining() -> float:
	return max(0.0, duration - timer)