class_name PlayerASPConfigContainer
extends BaseCharacterASPConfigContainer


## fs
## Preset: MAIN PLAYER (-4dB, Pan 0.3)
func _get_footstep_config() -> ASPConfig:
	return ASPConfig.new(-4.0, -0.0, 1.0, 30.0, 3, 0.3)

## Quieter (-10dB) and tighter distance
func _get_footstep_light_config() -> ASPConfig:
	return ASPConfig.new(-6.0, 0.0, 1.0, 20.0, 3, 0.3)

## Slightly lower pitch (-0.1) for friction feel
func _get_footstep_scrape_config() -> ASPConfig:
	return ASPConfig.new(-4.0, -0.1, 1.0, 30.0, 3, 0.3)

##

## Slightly louder (-2.0) and higher pitch (+0.1) for energy
func _get_launch_config() -> ASPConfig:
	return ASPConfig.new(-2.0, 0.1, 1.0, 30.0, 2, 0.3)

## Heavier: lower pitch (-0.1) and louder (-1.0) than footsteps
func _get_land_config() -> ASPConfig:
	return ASPConfig.new(-1.0, -0.1, 1.0, 30.0, 2, 0.3)


func _get_whoosh_config() -> ASPConfig:
	return ASPConfig.new(-5.0, -0.0, 1.0, 20.0, 3, 0.4)

func _get_move_noise_config() -> ASPConfig:
	return null
