class_name TimeUtils
extends RefCounted


## small division error, usually acceptable
static func get_curr_time_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func get_time_string_from_system_mm_ss() -> String:
	var time := Time.get_time_string_from_system()
	var mm_ss := time.right(5) if len(time) >= 5 else time
	return mm_ss


## WARNING: this is sytem dependent and usually not recommended
static func get_sys_unix_time() -> float:
	return Time.get_unix_time_from_system()