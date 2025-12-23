extends BasePHEAttack


func initialise_implementation() -> void:
	start_time_offset.set_by_prev_action({
		PHES.Leaf.dodge_B: 0.1,
	})
	hit_damage = 25

func get_anim_active_weapon_ids() -> Array[String]:
	return  [WeaponID.big_pinga_blade]