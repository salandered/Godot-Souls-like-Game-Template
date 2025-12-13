extends BaseRigidBodyPhysicsSFX
class_name DarkCrate


const WOOD_IMPACT: AudioStream = preload("uid://de0vjaija8veh")

func initialise_implementation() -> void:
	pass


func get_asp_config() -> ASPConfig:
	return ASPConfig.new(0.0, 0.0, 4.0, 15.0, 3, 0.5, "", WOOD_IMPACT)


## __LOGS
# region


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
