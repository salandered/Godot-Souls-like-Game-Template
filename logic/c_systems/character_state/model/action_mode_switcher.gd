extends RefCountedSystem
class_name ActionModeSwitcher


class Preset extends RefCounted:
	var mode_name: String
	var speed: float
	var anim_id: String

	func _init(mode_name_: String, speed_: float, anim_id_: String):
		self.mode_name = mode_name_
		self.speed = speed_
		self.anim_id = anim_id_

	func _to_string() -> String:
		return "Preset[%s, spd:%.1f, anim:%s]" % [mode_name, speed, anim_id]


enum MODE_NAME {ONE, TWO}

var _preset_one: Preset
var _preset_two: Preset


## most important souce of truth
var _curr_mode: MODE_NAME = MODE_NAME.ONE


func _init(preset_one: Preset, preset_two: Preset):
	self._preset_one = preset_one
	self._preset_two = preset_two


func _get_current_preset() -> Preset:
	if _curr_mode == MODE_NAME.ONE:
		return _preset_one
	else:
		return _preset_two


## Get info about currently active mode
# region

func get_curr_speed() -> float:
	return _get_current_preset().speed

func get_curr_anim_id() -> String:
	return _get_current_preset().anim_id

# internal enum (ONE or TWO) of the current mode
func get_curr_mode_raw() -> MODE_NAME:
	return _curr_mode

## custom name (e.g., "slow", "fast") of the current mode
func get_curr_mode_name() -> String:
	return _get_current_preset().mode_name

# endregion


func flip_mode():
	if _curr_mode == MODE_NAME.ONE:
		_curr_mode = MODE_NAME.TWO
	else:
		_curr_mode = MODE_NAME.ONE


## Sets the active mode using the custom name
func set_mode(custom_name: String):
	if _preset_one.mode_name == custom_name:
		_curr_mode = MODE_NAME.ONE
	elif _preset_two.mode_name == custom_name:
		_curr_mode = MODE_NAME.TWO
	else:
		__log_warn("ActionModeSwitcher: No mode found with name " + custom_name)


## Sets the active mode using the internal enum
func set_mode_raw(mode: MODE_NAME):
	_curr_mode = mode


func get_all_anim_ids() -> Array[String]:
	return [_preset_one.anim_id, _preset_two.anim_id]


## __LOGS
# region


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion
