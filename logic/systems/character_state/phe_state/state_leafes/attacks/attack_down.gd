extends BasePHEAttack


func initialise_implementation() -> void:
	hit_damage = 15

func get_active_weapon_names() -> Array[String]:
	return default_get_active_weapon_names()