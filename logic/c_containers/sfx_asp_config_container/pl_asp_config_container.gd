class_name PlayerASPConfigContainer
extends BaseCharacterASPConfigContainer

var fs_unite_size = 3.9
var fs_base = -2.4

## fs
## Preset: MAIN PLAYER (-4dB, Pan 0.3)
func _get_footstep_config() -> ASPConfig:
	return ASPConfig.new(fs_base, -0.0, fs_unite_size, 20.0, 3, 0.3)

## Quieter and tighter distance
func _get_footstep_light_config() -> ASPConfig:
	return ASPConfig.new(fs_base - 1.0, 0.0, fs_unite_size - 0.3, 20.0, 3, 0.3)

## Slightly lower pitch (-0.1) for friction feel
func _get_footstep_scrape_config() -> ASPConfig:
	return ASPConfig.new(fs_base, -0.1, fs_unite_size, 30.0, 3, 0.3)


func _get_jingle_config() -> ASPConfig:
	return null


##

## Slightly louder (-2.0) and higher pitch (+0.1) for energy
func _get_launch_config() -> ASPConfig:
	return ASPConfig.new(fs_base - 0.5, 0.0, fs_unite_size, 30.0, 2, 0.3)

## Heavier: lower pitch (-0.1) and louder (-1.0) than footsteps
func _get_land_config() -> ASPConfig:
	return ASPConfig.new(fs_base - 0.5, -0.1, fs_unite_size, 30.0, 2, 0.3)


func _get_whoosh_config() -> ASPConfig:
	return ASPConfig.new(-0.4, -0.1, 4.0, 20.0, 3, 0.4)


func _get_move_noise_config() -> ASPConfig:
	return null


func _get_react_on_hit_config() -> ASPConfig:
	return ASPConfig.new(-1.0, -0.1, 3.0, 40.0, 2, 0.4, BusID.GAME_SFX, BOW_IMPACT)


##
func _get_unique_config() -> ASPConfig:
	return ASPConfig.new()