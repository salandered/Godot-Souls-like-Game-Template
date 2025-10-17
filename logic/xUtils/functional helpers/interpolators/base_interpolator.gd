@abstract
class_name BaseInterpolator
extends RefCounted


var duration: float = -1.0
var timer: float = 0.0


## should have initialise()
## 	  - idempotent
##    - sets positive duration

## should have update()
##    - returns final value when done


func reset() -> void:
	timer = 0.0
	duration = -1.0


func is_initialised() -> bool:
	if duration == -1.0:
		return false
	return true


func is_complete() -> bool:
	if not is_initialised():
		return false
	return timer >= duration


func is_in_progress() -> bool:
	return is_initialised() and not is_complete()


func _get_progress() -> float:
	if duration == 0.0:
		return 0.0
	return clampf(timer / duration, 0.0, 1.0)
