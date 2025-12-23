extends BasePHEAttack


func initialise_implementation() -> void:
	default_sp.ANGULAR_SPEED = 1

	hit_damage = 10
	angle_adjustment_deg = 25


func get_anim_active_weapon_ids() -> Array[String]:
	return  [WeaponID.big_pinga_blade]