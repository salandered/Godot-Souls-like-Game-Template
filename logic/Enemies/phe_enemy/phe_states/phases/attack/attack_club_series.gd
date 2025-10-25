extends BasePHEAttackSeries
class_name PHEAttackClubSeries


func initialise() -> void:
	attack_to_number = {
		PHEState.Leaf.club_part_1: 0,
		PHEState.Leaf.club_part_2: 1,
		PHEState.Leaf.club_part_3_4: 2,
	}

	MIN_ATTACKS_TO_DO = 2
	MAX_ATTACKS_TO_DO = 3
