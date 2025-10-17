extends BaseVerdict
class_name SEVerdict


const CURRENT = "_current"

## NOTE: next_state by default is CURRENT
var request_new_iter: bool

func _init(_next_state: String = CURRENT, _request_new_iter: bool = false):
	if _next_state == "":
		next_state = CURRENT
	else:
		next_state = _next_state
	request_new_iter = _request_new_iter

func is_current() -> bool:
	return next_state == CURRENT
