class_name EnemyASPConfigContainer
extends BaseCharacterASPConfigContainer


var fs_unite_size = 3.9
var fs_base = -2.0

## fs like
func _get_footstep_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base + 1.0, -0.4, 4.0, 60.0, 3, 0.5)

## Quieter (-10dB) and tighter distance
func _get_footstep_light_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base - 3.0, -0.3, 4.0, 40.0, 3, 0.5)

## Slightly lower pitch (-0.1) for friction feel
func _get_footstep_scrape_config() -> ASP3DConfig:
	return ASP3DConfig.new(fs_base, -0.3, 4.0, 60.0, 3, 0.5)


func _get_move_noise_config() -> ASP3DConfig:
	return ASP3DConfig.new(-2.0, -0.0, 4.0, 40.0, 2, 0.4, BusID.GAME_SFX, BG_MOVE_NOISE)


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
	# Wide panning (0.7) to hear the air move across the stereo field.
	return ASP3DConfig.new(-2.0, -0.3, 3.0, 30.0, 3, 0.7)


func _get_react_on_hit_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.6, -0.3, 5.0, 40.0, 3, 0.4, BusID.GAME_SFX, SK_IMPACTS)

##
func _get_unique_config() -> ASP3DConfig:
	return ASP3DConfig.new()
