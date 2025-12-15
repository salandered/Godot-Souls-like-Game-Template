extends BasePHEAttack


func initialise_implementation() -> void:
	default_sp.ANGULAR_SPEED = 1
	sp_config = SpeedConfig.new(default_sp)
	blend_time.set_by_prev_action({
		PHES.Leaf.club_part_1: 0.2,
	})
	blend_time.set_specific(0.3)

	start_time_offset.set_by_prev_action({
		PHES.Leaf.club_part_1: 0.3,
	})

	hit_damage = 10


func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()