extends RefCounted
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

func __log_(...parts: Array):
	print_.prefix("Cycler", pp.list_(parts))

func __log_warn(what: String, where: String, fallback: String, ...context: Array):
	print_.warn(false, what, where, fallback, pp.list_(context))
