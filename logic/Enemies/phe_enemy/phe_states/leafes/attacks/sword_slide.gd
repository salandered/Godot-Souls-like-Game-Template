extends BasePHEAttack


func initialise_implementation():
	SCALE_ROOT_FACTOR = 1.4
	
	hit_damage = 30


func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()