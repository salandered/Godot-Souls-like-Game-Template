extends RefCountedStaticLogger
class_name AudioBusUtil


## Check if a bus exists by name
static func bus_exists(bus_name: String, warn_level: String = WL.SILENT) -> bool:
	var _r := AudioServer.get_bus_index(bus_name) != -1
	if _r == false:
		error_.warn(pp.s("Bus not found", bus_name), "", "", warn_level)
	return _r


## Mute/unmute a bus by name
static func _set_bus_mute(bus_name: String, muted: bool) -> void:
	if bus_exists(bus_name, WL.PUSH_WARN):
		var bus_idx := AudioServer.get_bus_index(bus_name)
		# "If true, the bus at index param bus_idx is muted."
		AudioServer.set_bus_mute(bus_idx, muted)


static func mute_bus(bus_name: String) -> void:
	_set_bus_mute(bus_name, true)


static func unmute_bus(bus_name: String) -> void:
	_set_bus_mute(bus_name, false)


## Check if bus is muted
static func is_bus_muted(bus_name: String) -> bool:
	if bus_exists(bus_name, WL.PUSH_WARN):
		var bus_idx := AudioServer.get_bus_index(bus_name)
		return AudioServer.is_bus_mute(bus_idx)
	else:
		return false


## Get all bus names
static func get_all_bus_names() -> Array[String]:
	var names: Array[String] = []
	for bus_idx: int in AudioServer.bus_count:
		names.append(AudioServer.get_bus_name(bus_idx))
	return names


# 

static func log_buses():
	print("\n=== LOG BUSES ===")
	print("Output latency: ", AudioServer.get_output_latency())
	print("Time to next mix: ", AudioServer.get_time_to_next_mix())
	
	for bus_idx in AudioServer.bus_count:
		var bus_name = AudioServer.get_bus_name(bus_idx)
		var peak_l = AudioServer.get_bus_peak_volume_left_db(bus_idx, 0)
		var peak_r = AudioServer.get_bus_peak_volume_right_db(bus_idx, 0)
		print("Bus %s: L=%.2f R=%.2f" % [bus_name, peak_l, peak_r])


## Add to Node 3D to make quick checks
# func _process(delta: float):
# 	if Input.is_action_just_pressed("ui_accept"):
# 		AudioBusUtil.log_buses()


# region: DANGER ZONE ----------

## Mute all buses
static func __mute_all() -> void:
	__log_warn_soft(pp.s(pp_name(), "gonna mute all"))
	for bus_idx in AudioServer.bus_count:
		AudioServer.set_bus_mute(bus_idx, true)

## Unmute all buses
static func __unmute_all() -> void:
	__log_warn_soft(pp.s(pp_name(), "gonna unmute all"))
	for bus_idx in AudioServer.bus_count:
		AudioServer.set_bus_mute(bus_idx, false)

# endregion
# ------------------------------


# region: __LOGS
static func pp_name() -> String:
	return "AudioBusUtil🎧"

static func __LOG_B() -> bool:
	return true

static func __LOG_INDENT() -> int:
	return 2

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion