extends RefCountedLogger
## to cycle through an array of values endlessly
class_name Cycler

var _values: Array = []
var _pointer: int = -1

func _init(values: Array):
	if values.is_empty():
		__log_warn("values is an empty array", "_init", "initialised with []")
	_values = values

## Returns the next value in the array, looping back to the start.
func get_next() -> Variant:
	if _values.is_empty():
		__log_warn("Cycler has no values to get", "", "return null")
		return null
	
	_pointer = (_pointer + 1) % _values.size()
	return _values[_pointer]

## Returns the current value without advancing the pointer.
## Returns the first value if get_next() has not been called.
func get_current() -> Variant:
	if _values.is_empty():
		__log_warn("Cycler has no values to get", "", "return null")
		return null
		
	if _pointer == -1:
		return _values[0]
	
	return _values[_pointer]


## __LOGS
# region

func pp_name() -> String:
	return "Cycler"

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion