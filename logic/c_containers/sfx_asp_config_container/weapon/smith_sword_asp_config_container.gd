class_name SmithSwordASPConfigContainer
extends BaseWeaponASPConfigContainer


## weapon

func _get_whoosh_weapon_config() -> ASPConfig:
	return ASPConfig.new(-1.0, -0.15, 4.5, 25.0, 4, 0.5, BusID.GAME_SFX, WEAPON_WHOOSH)


func _get_hit_weapon_config() -> ASPConfig:
	var a = AudioStreamRandomizer.new()
	return ASPConfig.new(-1.5, -0.0, 3.5, 30.0, 4, 0.5, BusID.GAME_SFX, HIT_SWORD)


func _get_hit_target_config() -> ASPConfig:
	return ASPConfig.new(-1.1, -0.0, 4.1, 30.0, 4, 0.5, BusID.GAME_SFX, HIT_BONE_ROCK_FALL_CAT)
