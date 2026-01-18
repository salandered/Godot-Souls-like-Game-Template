class_name SitSkASPConfigContainer
extends BaseCharacterASPConfigContainer


const BG_MOVE_NOISE_SITSK = preload("uid://dohiirmmxara3")
const BONE_SNAP_TRIMMED = preload("uid://yqejdlrkriea")
const ROCK_IMPACT_PICKING_8_SK_CLAP = preload("uid://culrf4q5fe23a")


## fs like
func _get_footstep_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.0, -0.1, 3.0, 12.0, 3, 0.7, BusID.GAME_SFX, BONE_SNAP_TRIMMED)

## Quieter (-10dB) and tighter distance
func _get_footstep_light_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.0 - 3.0, -0.3, 4.0, 40.0, 3, 0.5)

## Slightly lower pitch (-0.1) for friction feel
func _get_footstep_scrape_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.0, -0.3, 4.0, 60.0, 3, 0.5)


func _get_move_noise_config() -> ASP3DConfig:
	return ASP3DConfig.new(-2.0, -0.0, 4.0, 15.0, 2, 0.4, BusID.GAME_SFX, BG_MOVE_NOISE_SITSK)


func _get_jingle_config() -> ASP3DConfig:
	return ASP3DConfig.new(1.3, -0.1, 1.7, 25.0, 3, 0.4, BusID.GAME_SFX, JINGLES)

##

## Slightly louder (-2.0) and higher pitch (+0.1) for energy
func _get_launch_config() -> ASP3DConfig:
	return ASP3DConfig.new(-0.0, -0.3, 4.0, 60.0, 2, 0.6)

## Heavier: lower pitch (-0.1) and louder (-1.0) than footsteps
func _get_land_config() -> ASP3DConfig:
	return ASP3DConfig.new(1.0, -0.4, 5.0, 60.0, 2, 0.6)


func _get_whoosh_config() -> ASP3DConfig:
	return ASP3DConfig.new(-8.0, -0.0, 3.0, 14.0, 2, 0.7, BusID.GAME_SFX, ROCK_IMPACT_PICKING_8_SK_CLAP)


func _get_react_on_hit_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.6, -0.3, 5.0, 40.0, 3, 0.4, BusID.GAME_SFX, SK_IMPACTS)

##
func _get_unique_config() -> ASP3DConfig:
	return ASP3DConfig.new()
