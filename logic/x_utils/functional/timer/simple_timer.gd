extends BaseTimer
class_name SimpleTimer


## idempotent
func initialise(duration_: float) -> void:
	self.duration = duration_
	self.timer = 0.0

	
## Returns true when timer expires
func update(delta: float) -> bool:
	if not is_initialised(): return false
	
	if timer < duration:
		timer += delta
	return is_complete()
