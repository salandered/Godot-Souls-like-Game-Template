extends BasePHEAttack
class_name ClubPHEAttack


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)
	blend_time.set_by_prev_action({
		PHEState.Leaf.club_part_1: 0.2,
		PHEState.Leaf.club_part_2: 0.2,
	})
	blend_time.set_specific(0.3)

	start_time_offset.set_by_prev_action({
		PHEState.Leaf.club_part_1: 0.1,
		PHEState.Leaf.club_part_2: 0.1,
	})
