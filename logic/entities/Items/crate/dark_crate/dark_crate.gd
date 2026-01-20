extends BaseRigidBodyPhysicsSFX
class_name DarkCrate


func get_sound_cooldown() -> float:
	return 0.2
	
	
func initialise_implementation() -> void:
	pass


func get_asp_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.0, 0.0, 4.0, 15.0, 3, 0.5, "", WOOD_IMPACT)


## __LOGS
# region


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
