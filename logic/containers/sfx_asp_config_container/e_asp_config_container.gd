class_name EnemyASPConfigContainer
extends BaseCharacterASPConfigContainer


## fs
func _get_footstep_config() -> ASPConfig:
	return ASPConfig.new()

func _get_footstep_light_config() -> ASPConfig:
	return ASPConfig.new()

func _get_footstep_scrape_config() -> ASPConfig:
	return ASPConfig.new()

##
func _get_launch_config() -> ASPConfig:
	return ASPConfig.new()

func _get_land_config() -> ASPConfig:
	return ASPConfig.new()

func _get_whoosh_config() -> ASPConfig:
	return ASPConfig.new()

func _get_move_noise_config() -> ASPConfig:
	return ASPConfig.new()
