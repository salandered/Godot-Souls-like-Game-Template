## to cycle through an array of values endlessly
## make sure to initialise it as global var
class_name Cycler
extends RefCountedSystem


var _values: Array = []
var _pointer: int


# todo: consider duplicating values
func _init(values: Array, initial_pointer: int = 0):
	if values.is_empty():
		__log_warn("values is an empty array", "_init", "initialised with []")
	if initial_pointer >= 0 and initial_pointer <= len(values) - 1:
		_pointer = initial_pointer
	else:
		__log_warn("incorrect initial_pointer", "_init", "will be 0", initial_pointer)
		_pointer = 0
	_values = values


## Returns the next value in the array, looping back to the start.
func get_next() -> Variant:
	if _values.is_empty():
		__log_warn("Cycler has no values to get", "", "return null")
		return null
	
	_pointer = (_pointer + 1) % len(_values)
	return _pick_value()

## Returns the current value without advancing the pointer.
func get_current() -> Variant:
	if _values.is_empty():
		__log_warn("Cycler has no values to get", "", "return null")
		return null
	
	return _pick_value()


func get_current_pointer() -> int:
	return _pointer


func _is_pointer_within() -> bool:
	return _pointer >= 0 and _pointer <= len(_values) - 1

func _pick_value() -> Variant:
	if _is_pointer_within():
		return _values[_pointer]
	else:
		__log_error("critical cycler error. Probably array were changed externally", "", "return null", "Pointer/array size", _pointer, len(_values))
		return null

## __LOGS
# region


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
