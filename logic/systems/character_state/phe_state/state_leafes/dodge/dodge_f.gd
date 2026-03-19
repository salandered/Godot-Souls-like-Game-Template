extends BasePHEDodgeLeaf


var gap_calculator: GapJumpCalculator


func on_enter_state() -> void:
	var dist := distance_to_player()
	SCALE_LENGTH = 1.0
	if dist < config.ORBIT_RAD():
		gap_calculator = GapJumpCalculator.new(0.2)
		SCALE_LENGTH = gap_calculator.set_coef(dist, me.angry_raised)

	if dist > config.GAP_CLOSER_RAD():
		gap_calculator = GapJumpCalculator.new(0.2)
		SCALE_LENGTH = gap_calculator.set_coef(dist, me.angry_raised)
