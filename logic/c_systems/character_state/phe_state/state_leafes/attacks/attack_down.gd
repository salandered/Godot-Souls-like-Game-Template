extends BasePHEAttack


func initialise_implementation() -> void:
	hit_damage = 15

func get_anim_active_weapon_ids() -> Array[String]:
	return  [WeaponID.big_pinga_blade]