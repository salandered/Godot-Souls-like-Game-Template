class_name EventThrottler
extends RefCounted

var _throttle_window: float
var _history_window_mult: float
var _history: Dictionary[int, float] = {}


## NOTE: Only int keys are supported
## expected that will be used with keys as built Godot instand_id

func _init(window_seconds_: float, history_window_mult_: float = 2.0):
	self._throttle_window = window_seconds_
	self._history_window_mult = history_window_mult_


## Returns TRUE if the event is "too soon" and should be skipped.
## Pass 'current_time' to avoid multiple OS calls per frame.
func is_throttled(key: int, current_time: float) -> bool:
	if not key in _history:
		return false
	
	var last_time: float = _history[key]
	return (current_time - last_time) < _throttle_window


## Updates the timestamp for the given key.
func record_event(key: int, current_time: float) -> void:
	_history[key] = current_time


## Removes old entries to prevent memory leaks.
## Call this once per frame or periodically.
func cleanup(current_time: float) -> void:
	var threshold := _throttle_window * _history_window_mult
	var keys_to_remove: Array[int] = []
	
	for key: int in _history:
		if (current_time - _history[key]) > threshold:
			keys_to_remove.append(key)
	
	for key: int in keys_to_remove:
		_history.erase(key)