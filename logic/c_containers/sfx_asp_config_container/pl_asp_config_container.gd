class_name PlayerASPConfigContainer
extends BaseCharacterASPConfigContainer

var fs_unite_size := 3.9
var fs_base := -2.4 - 4.0

## fs
## Preset: MAIN PLAYER (-4dB, Pan 0.3)
func _get_footstep_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base, 0.0, fs_unite_size, 20.0, 3, 0.3)

## Quieter and tighter distance
func _get_footstep_light_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base - 1.0, 0.0, fs_unite_size - 0.3, 20.0, 3, 0.3)

## Slightly lower pitch (-0.1) for friction feel
func _get_footstep_scrape_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base, -0.1, fs_unite_size, 30.0, 3, 0.3)


func _get_jingle_config() -> ASP3DConfig:
	return null


##

## Slightly louder (-2.0) and higher pitch (+0.1) for energy
func _get_launch_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base - 0.5, 0.0, fs_unite_size, 30.0, 2, 0.3)

## Heavier: lower pitch (-0.1) and louder (-1.0) than footsteps
func _get_land_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base + 2.0, -0.1, fs_unite_size, 30.0, 2, 0.3)


func _get_whoosh_config() -> ASP3DConfig:
	return ASP3DConfig.new(-0.4, -0.1, 4.0, 20.0, 3, 0.4)


func _get_move_noise_config() -> ASP3DConfig:
	return null


func _get_react_on_hit_config() -> ASP3DConfig:
	return ASP3DConfig.new(-1.0, -0.1, 3.0, 40.0, 2, 0.4, BusID.GAME_SFX, BOW_IMPACT)


##
func _get_unique_config() -> ASP3DConfig:
	return ASP3DConfig.new()