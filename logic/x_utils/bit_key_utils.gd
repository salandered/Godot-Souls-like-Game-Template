class_name BitKeyUtils
extends RefCounted

## 16-bit shift.
## allows for 65535 enum entries
const _SHIFT_BITS = 16
const _LIMIT = 65535


## combines two enum integers into a single composite key.
static func combine(high_a: int, low_b: int) -> RO.IntReturn:
	if high_a < 0 or low_b < 0:
		error_.warn("BitKey invalid: values must be non-negative", "", "", WL.PUSH_WARN, high_a, low_b)
		return RO.IntReturn.new(true)

	if high_a > _LIMIT or low_b > _LIMIT:
		error_.warn(pp.s("BitKey overflow: values must be <=", _LIMIT), "", "", WL.PUSH_WARN, high_a, low_b)
		return RO.IntReturn.new(true)
	
	var key: int = (high_a << _SHIFT_BITS) | low_b
	return RO.IntReturn.new(false, key)


## splitting the key back into components
static func split(key: int) -> RO.Vector2iReturn:
	if key < 0:
		error_.warn("BitKey invalid: key cannot be negative", "", "", WL.PUSH_WARN, key)
		return RO.Vector2iReturn.new(true)

	var low_b: int = key & _LIMIT
	var high_a: int = key >> _SHIFT_BITS
	
	return RO.Vector2iReturn.new(false, Vector2i(high_a, low_b))


## returns a debug string like "[2, 5]"
static func pp_split_result(key: int) -> String:
	var r := split(key)
	if r.err:
		return "[BitKey Error: Invalid Key %d]" % key

	return "[%d, %d]" % [r.value.x, r.value.y]


## e.g.: BitKeyUtils.pp_split_result_named(key, CharacterType, DevVisualsType)
static func pp_split_result_named(key: int, enum_a: Dictionary, enum_b: Dictionary) -> String:
	var r := split(key)
	if r.err:
		return "[BitKey Error: Invalid Key %d]" % key
	
	var name_a := _find_enum_name(enum_a, r.value.x)
	var name_b := _find_enum_name(enum_b, r.value.y)
	
	return "[%s | %s]" % [name_a, name_b]


## HELPERS

static func _find_enum_name(enum_dict: Dictionary, value: int) -> String:
	var key = enum_dict.find_key(value)
	if key:
		return str(key)
	return str(value)
