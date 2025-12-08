extends BasePHEDodgeLeaf


# to override instead of initialise
func initialise_implementation():
	match PREV_LEAF:
		PHES.Leaf.dodge_B:
			SCALE_LENGTH = fvalue_angry(1.2, 1.7)
		_:
			SCALE_LENGTH = fvalue_angry(1.0, 1.2)
