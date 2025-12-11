class_name SmithSwordASPConfigContainer
extends BaseWeaponASPConfigContainer


const WEAPON_WHOOSH: AudioStream = preload("uid://qufmydm4eeq4")
const METAL_SWORD_HIT: AudioStream = preload("uid://g4dtkcleinh8")
const HIT_BONE_ROCK_FALL_CAT: AudioStream = preload("uid://bi76gdwpvrkw7")


## weapon

func _get_whoosh_weapon_config() -> ASPConfig:
	# Thick blade displacement.
	# Pitch (-0.15) adds "weight" without feeling slow.
	# Unit Size (1.5) & Pan (0.5) reflect a wider, heavier swing arc.
	return ASPConfig.new(-3.0, -0.15, 1.5, 25.0, 4, 0.5, WEAPON_WHOOSH)


func _get_hit_weapon_config() -> ASPConfig:
	# Heavy impact.
	# Louder (-1.0) and slightly lower pitch (-0.1) for a "crunchy" hit.
	return ASPConfig.new(-1.0, -0.1, 1.5, 30.0, 4, 0.5, METAL_SWORD_HIT)


func _get_hit_target_config() -> ASPConfig:
	return ASPConfig.new(-1.0, -0.0, 1.5, 30.0, 4, 0.5, HIT_BONE_ROCK_FALL_CAT)
