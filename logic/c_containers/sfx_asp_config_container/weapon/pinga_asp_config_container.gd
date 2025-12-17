class_name PingaASPConfigContainer
extends BaseWeaponASPConfigContainer


## weapon

func _get_whoosh_weapon_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.4, -0.3, 3.0, 60.0, 4, 0.5, BusID.GAME_SFX, HEAVY_WHOOSH)


func _get_hit_weapon_config() -> ASP3DConfig:
	return ASP3DConfig.new(1.0, -0.3, 3.0, 70.0, 4, 0.7, BusID.GAME_SFX, HIT_SWORD)


func _get_hit_target_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.0, -0.4, 5.0, 70.0, 4, 0.7, BusID.GAME_SFX, HIT_BONE_ROCK_FALL_CAT)
