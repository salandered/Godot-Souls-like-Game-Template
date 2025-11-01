extends BasePHELeaf



func update(delta):
	if time_remaining() <= 0.1:
		me.queue_free()
