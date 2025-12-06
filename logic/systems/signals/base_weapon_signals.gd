extends BaseSignals
class_name BaseWeaponSignals

signal SFX_hit_weapon(data: Dictionary[String, Variant])
signal SFX_whoosh_weapon(data: Dictionary[String, Variant])


func get_SFX_whoosh_weapon() -> Signal:
	return SFX_whoosh_weapon

func get_SFX_hit_weapon() -> Signal:
	return SFX_hit_weapon
