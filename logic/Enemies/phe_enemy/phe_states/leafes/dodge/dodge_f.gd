extends BasePHEDodgeLeaf


var gap_calculator: GapJumpCalculator


func on_enter_state() -> void:
	SCALE_LENGTH = 1.0
	if dist_to_player_less(config.ORBIT_RAD()):
		gap_calculator = GapJumpCalculator.new(0.2)
		SCALE_LENGTH = gap_calculator.set_coef(distance_to_player(), me.angry_raised)


	if dist_to_player_greater(config.GAP_CLOSER_RAD()):
		gap_calculator = GapJumpCalculator.new(0.2)
		SCALE_LENGTH = gap_calculator.set_coef(distance_to_player(), me.angry_raised)
