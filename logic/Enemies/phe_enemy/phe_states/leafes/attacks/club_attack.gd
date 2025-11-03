extends BasePHEAttack
class_name ClubPHEAttack


func initialise_implementation() -> void:
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)
	blend_time.set_by_prev_action({
		PHES.Leaf.club_part_1: 0.2,
		PHES.Leaf.club_part_2: 0.3,
	})
	blend_time.set_specific(0.3)

	start_time_offset.set_by_prev_action({
		PHES.Leaf.club_part_1: 0.3,
		PHES.Leaf.club_part_2: 0.1,
	})


# var __blend__2 = 0.0
# var __offset_2 = 0.0

# func _input(event: InputEvent) -> void:
# 	__blend__2 = u._dev_change_t34_param(event, __blend__2, "__blend__2", 0.1)
# 	__offset_2 = u._dev_change_t67_param(event, __offset_2, "__offset_2", 0.1)

# 	blend_time.set_by_prev_action({
# 		PHES.Leaf.club_part_1: __blend__2,
# 		PHES.Leaf.club_part_2: 0.3,
# 	})

# 	start_time_offset.set_by_prev_action({
# 		PHES.Leaf.club_part_1: __offset_2,
# 		PHES.Leaf.club_part_2: 0.1,
# 	})