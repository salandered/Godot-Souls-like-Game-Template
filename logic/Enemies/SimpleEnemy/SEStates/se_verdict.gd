extends Resource
class_name Verdict


const CURRENT = "_current"

## NOTE: By default is CURRENT
var next_state: String
var request_new_iter: bool

func _init(_next_state: String = CURRENT, _request_new_iter: bool = false):
	if _next_state == "":
		next_state = CURRENT
	else:
		next_state = _next_state
	request_new_iter = _request_new_iter

func is_current() -> bool:
	return next_state == CURRENT
