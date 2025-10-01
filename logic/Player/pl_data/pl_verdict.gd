extends RefCounted
class_name PLVerdict

## Empty string means not needs_switch
var next_state: String
## dev
var comment: String

func _init(_next_state: String = "", _comment: String = ""):
	next_state = _next_state
	comment = _comment

func needs_switch() -> bool:
	return next_state != ""
