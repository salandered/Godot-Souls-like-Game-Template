extends BaseTimer
class_name DelayTimer


## idempotent
func initialise(duration_: float) -> void:
	duration = duration_
	timer = 0.0

	
## Returns true when timer expires
func update(delta: float) -> bool:
	if timer < duration:
		timer += delta
	return is_complete()


func reset() -> void:
	timer = 0.0