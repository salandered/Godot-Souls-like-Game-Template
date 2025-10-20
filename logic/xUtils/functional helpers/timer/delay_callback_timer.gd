extends BaseTimer
class_name DelayCallbackTimer

var on_complete: Callable = Callable() # Optional callback
var _has_triggered: bool = false # Prevent multiple calls to callback


## idempotent
func initialise(duration_: float, callback: Callable = Callable()) -> void:
	duration = duration_
	timer = 0.0
	on_complete = callback
	_has_triggered = false


## Returns true when timer expires
func update(delta: float) -> bool:
	if not is_initialised(): return false

	if timer < duration:
		timer += delta
		
	if is_complete() and not _has_triggered and on_complete.is_valid():
		on_complete.call()
		_has_triggered = true
	
	return is_complete()


## overrides
func reset() -> void:
	timer = 0.0
	_has_triggered = false # allow re-triggering after reset


## overrides
func turn_off() -> void:
	timer = 0.0
	duration = -1.0
	_has_triggered = false