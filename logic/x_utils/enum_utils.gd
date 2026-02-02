class_name EnumUtils
extends RefCounted


## if int 'value' exists as a value in the 'enum_dict'.
## Usage: EnumUtils.safe_has_value(MyEnum, 5)
static func safe_has_value(enum_dict: Dictionary, value: int, warn_level: String = WL.WARN) -> bool:
	var exists: bool = enum_dict.values().has(value)
	if not exists:
		error_.warn(_msg_enum_value_problem(value, enum_dict), "", "", warn_level)
	return exists

## if string 'key' exists as a key in the 'enum_dict'.
## Usage: EnumUtils.safe_has_key(MyEnum, "PLAYER")
static func safe_has_key(enum_dict: Dictionary, key: String, warn_level: String = WL.WARN) -> bool:
	var exists: bool = enum_dict.has(key)
	if not exists:
		error_.warn(_msg_enum_key_problem(key, enum_dict), "", "", warn_level)
	return exists

## Helpers

static func _msg_enum_value_problem(value: int, enum_dict: Dictionary) -> String:
	var _msg := pp.s("Enum Value", pp.in_q(value), "not found in enum values:", enum_dict.values())
	return _msg

static func _msg_enum_key_problem(key: String, enum_dict: Dictionary) -> String:
	var _msg := pp.s("Enum Key", pp.in_q(key), "not found in enum keys:", enum_dict.keys())
	return _msg