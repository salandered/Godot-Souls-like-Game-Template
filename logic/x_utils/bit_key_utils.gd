class_name BitKeyUtils
extends RefCounted

## Standard 16-bit shift. 
## allows for 65535 enum entries
const _SHIFT_BITS = 16
const _LIMIT = 65535

## Combines two enum integers into a single composite key.
## Returns RO.IntReturn
static func combine(high_a: int, low_b: int) -> RO.IntReturn:
	## 1. Non-negative check
	if high_a < 0 or low_b < 0:
		error_.warn("BitKey invalid: values must be non-negative", "", "", WL.PUSH_WARN, high_a, low_b)
		return RO.IntReturn.new(true)

	## 2. Limit check
	if high_a > _LIMIT or low_b > _LIMIT:
		error_.warn(pp.s("BitKey overflow: values must be <=", _LIMIT), "", "", WL.PUSH_WARN, high_a, low_b)
		return RO.IntReturn.new(true)
	
	var key: int = (high_a << _SHIFT_BITS) | low_b
	return RO.IntReturn.new(false, key)


## Splitting the key back into components.
## Returns Vector2i(high_a, low_b) wrapped in a return object.
static func split(key: int) -> RO.Vector2iReturn:
	## 1. Basic validity check
	if key < 0:
		error_.warn("BitKey invalid: key cannot be negative", "", "", WL.PUSH_WARN, key)
		return RO.Vector2iReturn.new(true)

	var low_b: int = key & _LIMIT
	var high_a: int = key >> _SHIFT_BITS
	
	return RO.Vector2iReturn.new(false, Vector2i(high_a, low_b))


## Returns a debug string like "[2, 5]" or an error message.
static func to_s(key: int) -> String:
	var r := split(key)
	if r.err:
		return "[BitKey Error: Invalid Key %d]" % key

	return "[%d, %d]" % [r.value.x, r.value.y]


## Pass actual Enum dictionaries to get names like "[PLAYER | HITBOX]"
## E.g: BitKeyUtils.to_s_named(key, CharacterType, DevVisualsType)
static func to_s_named(key: int, enum_a: Dictionary, enum_b: Dictionary) -> String:
	var r := split(key)
	if r.err:
		return "[BitKey Error: Invalid Key %d]" % key
	
	var name_a := _find_enum_name(enum_a, r.value.x)
	var name_b := _find_enum_name(enum_b, r.value.y)
	
	return "[%s | %s]" % [name_a, name_b]


## Internal Helper
static func _find_enum_name(enum_dict: Dictionary, value: int) -> String:
	var key = enum_dict.find_key(value)
	if key:
		return str(key)
	return str(value)
