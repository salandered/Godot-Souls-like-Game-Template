class_name GenericRigid
extends BaseRigidBodyPhysicsSFX


func get_impact_threshold() -> float:
	return 0.2



func get_sound_cooldown() -> float:
	return 0.2
	
	
func initialise_implementation() -> void:
	pass


func get_asp_config() -> ASP3DConfig:
	return ASP3DConfig.new(0.0, 0.0, 4.0, 9.0, 2, 0.6, "", WOOD_IMPACT)


##

func __LOG_B() -> bool:
	return false
