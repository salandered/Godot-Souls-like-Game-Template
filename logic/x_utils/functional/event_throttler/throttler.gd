class_name EventThrottler
extends RefCountedLogger


var _THROTTLE_WINDOW: float
var _HISTORY_WINDOW: float
var _history: Dictionary[Variant, float] = {}


var _last_cleanup_time: float
var _auto_cleanup_interval: float

var _pp_name: String
var __log: bool

## NOTE: Dict key is untyped.
## expected that will be int if using built Godot instand_id
## strings are also fine


func _init(
		window_seconds_: float,
		history_window_mult_: float = 2.0,
		auto_cleanup_interval_: float = 3.0,
		pp_name_: String = "",
		__log__: bool = false
	):
	self._THROTTLE_WINDOW = window_seconds_
	self._HISTORY_WINDOW = window_seconds_ * history_window_mult_
	self._auto_cleanup_interval = auto_cleanup_interval_

	self._last_cleanup_time = 0.0

	self._pp_name = pp_name_
	self.__log = __log__


## Returns 'true' if the event is "too soon" and should be skipped
func is_throttled(key: Variant) -> bool:
	if not key in _history:
		return false
	
	var last_time: float = _history[key]
	var delta_time := _get_curr_time() - last_time
	var _r: bool = delta_time < _THROTTLE_WINDOW
	if _r and __log:
		__log_("throttled!" + em.mark_alt, "using", key, "and", delta_time, "vs", _THROTTLE_WINDOW)
	return _r


## Updates the timestamp for the given key
func record_event(key: Variant, auto_cleanup: bool = true) -> void:
	var now := _get_curr_time()
	_history[key] = now
	if auto_cleanup:
		if now - _last_cleanup_time > _auto_cleanup_interval:
			cleanup()
			_last_cleanup_time = now


## Removes old entries to prevent memory leaks
## Call this or use auto_cleanup
func cleanup() -> void:
	var now := _get_curr_time()
	var keys_to_remove: Array[Variant] = []
	
	for key: Variant in _history:
		if now - _history[key] > _HISTORY_WINDOW:
			keys_to_remove.append(key)
	
	for key: Variant in keys_to_remove:
		_history.erase(key)


func _get_curr_time() -> float:
	return TimeUtils.get_curr_time_ticks_sec()


## __LOGS
# region

func pp_name() -> String:
	return pp.s(_pp_name, "Throttler") if _pp_name != "" else super.pp_name()


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion