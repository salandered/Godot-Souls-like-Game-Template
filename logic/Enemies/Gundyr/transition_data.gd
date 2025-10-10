extends BaseVerdict
class_name VerdictHSM


## VerdictHSM.new() means no need to switch

func needs_switch() -> bool:
	return next_state != ""