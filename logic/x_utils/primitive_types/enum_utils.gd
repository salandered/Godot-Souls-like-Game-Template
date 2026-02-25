class_name EnumUtils
## can be seen as a sugar wrapper of Dict utils
extends RefCounted


## if int 'value' exists as a value in the 'enum_dict'.
## Usage: EnumUtils.safe_has_value(MyEnum, 5)
static func safe_has_value(enum_dict: Dictionary, value: int, wl: StringName = WL.INFO) -> bool:
	var exists: bool = enum_dict.values().has(value)
	if not exists:
		error_.warn(_msg_enum_value_problem(value, enum_dict), "", "", wl)
	return exists


## if string 'key' exists as a key in the 'enum_dict'.
## Usage: EnumUtils.safe_has_key(MyEnum, "PLAYER")
static func safe_has_key(enum_dict: Dictionary, key: String, wl: StringName = WL.INFO) -> bool:
	var exists: bool = enum_dict.has(key)
	if not exists:
		error_.warn(_msg_enum_key_problem(key, enum_dict), "", "", wl)
	return exists


## Cycles to the next enum value (0 -> 1 -> ... -> N -> 0).
## Assumes standard zero-based sequential enum.
static func cycle_sequential(enum_dict: Dictionary, current_value: int) -> int:
	return (current_value + 1) % enum_dict.size()


## Safely gets the string key name. Returns "UNKNOWN" if not found.
static func get_name_safe(enum_dict: Dictionary, value: int) -> String:
	var keys = enum_dict.keys()
	if value >= 0 and value < keys.size():
		return keys[value]
	# Fallback to avoid crash
	return "UNKNOWN"


## Returns an Array of values, excluding the key "UNKNOWN" if it exists.
## Usage: var types = EnumUtils.get_values_excluding_unknown(DVS.CharacterType)
static func get_values_excluding_unknown(enum_dict: Dictionary) -> Array:
	var values: Array = []
	for key in enum_dict:
		if key != "UNKNOWN":
			values.append(enum_dict[key])
	return values


## HELPERS

static func _msg_enum_value_problem(value: int, enum_dict: Dictionary) -> String:
	var _msg := pp.s("Enum Value", pp.in_q(value), "not found in enum values:", enum_dict.values())
	return _msg


static func _msg_enum_key_problem(key: String, enum_dict: Dictionary) -> String:
	var _msg := pp.s("Enum Key", pp.in_q(key), "not found in enum keys:", enum_dict.keys())
	return _msg
