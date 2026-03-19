class_name BaseTimer
extends RefCounted


var duration: float = -1.0
var timer: float = 0.0


## func initialize(...) -> void
## 	  - idempotent
##    - sets positive duration


## func update(delta: float, ...) -> bool
## 	  - returns true when timer expires


## hard reset, timer needs to be initialized again
func turn_off() -> void:
	timer = 0.0
	duration = -1.0


## resets to zero, but timer is ready to be updated
func reset() -> void:
	timer = 0.0


func is_initialized() -> bool:
	if duration == -1.0:
		return false
	return true


func is_complete() -> bool:
	if not is_initialized():
		return false
	return timer >= duration


func is_in_progress() -> bool:
	return is_initialized() and not is_complete()


func get_elapsed() -> float:
	return timer


func get_progress() -> float:
	if not is_initialized():
		return 0.0
	if duration == 0.0:
		return 0.0

	return timer / duration


func get_remaining() -> float:
	return max(0.0, duration - timer)