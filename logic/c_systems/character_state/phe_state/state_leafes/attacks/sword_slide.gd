extends BasePHEAttack


func initialise_implementation():
	SCALE_ROOT_FACTOR = 1.4
	
	hit_damage = 30


func get_anim_active_weapon_ids() -> Array[String]:
	return [WeaponID.big_pinga_blade]