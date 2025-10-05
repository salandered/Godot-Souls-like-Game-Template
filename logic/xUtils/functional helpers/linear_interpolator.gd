extends RefCounted
class_name FloatLinearInterpolator

var start_value: float
var target_value: float
var current_value: float
var timer: float = 0.0
var duration: float

## idempotent
func initialise(start: float, target: float, duration_: float) -> void:
	start_value = start
	target_value = target
	current_value = start
	duration = duration_
	timer = 0.0

## Returns target_value when done
func update(delta: float) -> float:
	if timer < duration:
		timer += delta
		var weight = clampf(timer / duration, 0.0, 1.0)
		current_value = lerp(start_value, target_value, weight)
	else:
		current_value = target_value
	return current_value

func is_complete() -> bool:
	return timer >= duration
