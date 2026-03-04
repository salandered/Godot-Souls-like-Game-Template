class_name RigidShatter
extends BaseRigidBodyPhysicsSFX


const ROCK_IMPACT_PICKING_8 = preload("uid://vadklygsmkv6")


## config
func get_impact_threshold() -> float:
	return 0.7


func get_sound_cooldown() -> float:
	return 0.7

func get_max_contacts_reported_() -> int:
	return 2
##


func initialize_implementation() -> void:
	pass


func get_asp_config() -> ASP3DConfig:
	return ASP3DConfig.new(-1.0, -0.3, 1.1, 40.0, 5, 0.5, "", ROCK_IMPACT_PICKING_8)


## __LOGS
# region


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
