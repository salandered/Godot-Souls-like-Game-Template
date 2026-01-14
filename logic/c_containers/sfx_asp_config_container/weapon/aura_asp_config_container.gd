class_name AuraASPConfigContainer
extends BaseWeaponASPConfigContainer


## weapon

var base_vol := -0.5

func _get_whoosh_weapon_config() -> ASP3DConfig:
	return ASP3DConfig.new(base_vol + 0.0, -0.1, 5.0, 50.0, 4, 0.3, BusID.GAME_SFX, AURA_PICKING_3)


func _get_hit_weapon_config() -> ASP3DConfig:
	return ASP3DConfig.new(base_vol - 2.0, -0.2, 6.0, 80.0, 3, 0.5, BusID.GAME_SFX, TORCH_ATTACK)


func _get_hit_target_config() -> ASP3DConfig:
	# Being hit by the shockwave.\
	return ASP3DConfig.new(base_vol - 2.0, -0.1, 4.0, 80.0, 4, 0.5, BusID.GAME_SFX, BIG_CRASH_ROCK)

# preload("uid://55u8tufkkk18")
