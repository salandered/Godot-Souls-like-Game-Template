extends BasePHELeaf


func react_on_hit(hit: HitData):
	## mute
	pass


func is_ended() -> bool:
	return time_remaining() <= 0.05
