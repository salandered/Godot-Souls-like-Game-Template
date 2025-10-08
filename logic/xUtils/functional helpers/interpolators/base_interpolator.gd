@abstract
class_name BaseInterpolator
extends RefCounted


var duration: float = 1.0
var timer: float = 0.0


## should have initialise()
## 	  - idempotent

## should have update()
##    - returns final value when done

func reset() -> void:
	timer = 0.0

func is_complete() -> bool:
	return timer >= duration


func _get_progress() -> float:
	if duration == 0.0:
		return 0.0
	return clampf(timer / duration, 0.0, 1.0)
