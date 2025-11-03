extends BasePHELeaf


func is_ended() -> bool:
	return time_remaining() <= 0.05

