extends BasePHEDodgeLeaf


# to override instead of initialise
func initialise_implementation():
	match PREV_LEAF:
		PHEState.Leaf.dodge_B:
			SCALE_LENGTH = 1.2 if not me.angry_raised else 1.5
		_:
			SCALE_LENGTH = 1.0 if not me.angry_raised else 1.2
