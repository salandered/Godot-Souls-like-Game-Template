extends BaseVerdict
class_name PLVerdict


func needs_switch() -> bool:
	return next_state != ""
