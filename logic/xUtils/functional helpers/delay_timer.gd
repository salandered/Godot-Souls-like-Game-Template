extends RefCounted
class_name DelayTimer

var duration: float
var timer: float = 0.0

## idempotent
func initialise(duration_: float) -> void:
	duration = duration_
	timer = 0.0

## Returns true when timer expires
func update(delta: float) -> bool:
	if timer < duration:
		timer += delta
	return is_complete()

func is_complete() -> bool:
	return timer >= duration

func reset() -> void:
	timer = 0.0

func get_elapsed() -> float:
	return timer

func get_remaining() -> float:
	return max(0.0, duration - timer)