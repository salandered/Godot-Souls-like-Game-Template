extends RefCountedStaticLogger
class_name AudioServerUtil


const DEV_BUS_PREFIX := "_d_"
const TEST_BUS_PREFIX := "_t_"

## Check if a bus exists by name
static func bus_exists(bus_name: String, warn_level: String = WL.SILENT) -> bool:
	var _r := _get_bus_idx(bus_name) != -1
	if _r == false:
		error_.warn(pp.s("Bus not found", bus_name), "", "", warn_level)
	return _r


static func mute_bus(bus_name: String) -> void:
	_set_bus_mute(bus_name, true)


static func unmute_bus(bus_name: String) -> void:
	_set_bus_mute(bus_name, false)


static func is_bus_muted(bus_name: String) -> bool:
	if bus_exists(bus_name, WL.PUSH_WARN):
		var bus_idx := _get_bus_idx(bus_name)
		return AudioServer.is_bus_mute(bus_idx)
	else:
		return false


## Get all bus names. Can be filtered with prefix.
static func get_all_bus_names(prefix: String = "") -> Array[String]:
	var names: Array[String] = []
	for bus_idx: int in AudioServer.bus_count:
		var bus_name := AudioServer.get_bus_name(bus_idx)
		if prefix == "" or bus_name.begins_with(prefix):
			names.append(bus_name)
	return names


static func get_dev_bus_names() -> Array[String]:
	return get_all_bus_names(DEV_BUS_PREFIX)

static func get_test_bus_names() -> Array[String]:
	return get_all_bus_names(TEST_BUS_PREFIX)

static func mute_test_buses() -> void:
	return __mute_all(TEST_BUS_PREFIX)


static func get_lowpass_filter(bus_name: String) -> AudioEffectLowPassFilter:
	var bus_idx := _get_bus_idx(bus_name)
	if bus_idx == -1:
		return null
	
	var effect_count := AudioServer.get_bus_effect_count(bus_idx)
	for effect_idx in range(effect_count):
		var effect := AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectLowPassFilter:
			return effect
	return null


## Returns the SpectrumAnalyzerInstance from a bus, or null if not found.
static func get_spectrum_analyzer(bus_name: String) -> AudioEffectSpectrumAnalyzerInstance:
	var bus_idx := _get_bus_idx(bus_name)
	if bus_idx == -1:
		error_.warn(pp.s("Bus not found", bus_name), "", "", WL.PUSH_WARN)
		return null
	
	var effect_count := AudioServer.get_bus_effect_count(bus_idx)
	for effect_idx in range(effect_count):
		var effect := AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectSpectrumAnalyzer:
			# We found the resource, now request the active instance from the server
			return AudioServer.get_bus_effect_instance(bus_idx, effect_idx)
			
	error_.warn(pp.s("SpectrumAnalyzer not found on bus", bus_name), "", "", WL.PUSH_WARN)
	return null

# 


static func log_buses():
	print("\n=== LOG BUSES ===")
	print("Output latency: ", AudioServer.get_output_latency())
	print("Time to next mix: ", AudioServer.get_time_to_next_mix())
	
	for bus_idx in AudioServer.bus_count:
		var bus_name := AudioServer.get_bus_name(bus_idx)
		var peak_l := AudioServer.get_bus_peak_volume_left_db(bus_idx, 0)
		var peak_r := AudioServer.get_bus_peak_volume_right_db(bus_idx, 0)
		print("Bus %s: L=%.2f R=%.2f" % [bus_name, peak_l, peak_r])


#


static func _get_bus_idx(bus_name: String) -> int:
	var _r := AudioServer.get_bus_index(bus_name)
	return _r


static func _set_bus_mute(bus_name: String, muted: bool) -> void:
	if bus_exists(bus_name, WL.PUSH_WARN):
		var bus_idx := AudioServer.get_bus_index(bus_name)
		# "If true, the bus at index param bus_idx is muted."
		AudioServer.set_bus_mute(bus_idx, muted)

## Add to Node 3D to make quick checks
# func _process(delta: float):
# 	if Input.is_action_just_pressed("ui_accept"):
# 		AudioServerUtil.log_buses()


# region: DANGER ZONE ----------
# called from the class functions, but advised not to call in from anywhere else.

static func __mute_all(prefix: String = "") -> void:
	__log_(pp.s(pp_name(), "gonna mute all", __log_prefix(prefix)))
	var bus_names := get_all_bus_names(prefix)
	for name_ in bus_names:
		mute_bus(name_)
		

static func __unmute_all(prefix: String = "") -> void:
	__log_(pp.s(pp_name(), "gonna unmute all", __log_prefix(prefix)))
	var bus_names := get_all_bus_names(prefix)
	for name_ in bus_names:
		unmute_bus(name_)

# endregion
# ------------------------------


static func __log_prefix(prefix: String) -> String:
	return pp.s("with prefix", pp.in_q(prefix)) if prefix != "" else ""

# region: __LOGS
static func pp_name() -> String:
	return "AudioServerUtil🎧"

static func __LOG_B() -> bool:
	return true

static func __LOG_INDENT() -> int:
	return 2

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion
