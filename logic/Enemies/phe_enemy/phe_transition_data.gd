extends BaseVerdict
class_name VerdictPH


## VerdictPH.new() means no need to switch

func needs_switch() -> bool:
	return next_state != ""