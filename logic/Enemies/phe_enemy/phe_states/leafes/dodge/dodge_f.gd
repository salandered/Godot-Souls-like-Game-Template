extends BasePHEDodgeLeaf


func on_enter_state() -> void:
	SCALE_LENGTH = 1.0
	if dist_to_player_less(config.ORBIT_RAD()):
		SCALE_LENGTH = 0.7
	elif dist_to_player_less(config.COMBAT_RAD()):
		SCALE_LENGTH = 0.4
