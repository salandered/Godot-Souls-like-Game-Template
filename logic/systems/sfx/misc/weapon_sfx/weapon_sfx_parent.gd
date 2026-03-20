extends Node3DSystem
class_name WeaponSFXParent


@onready var sfx_system: BaseWeaponSFXSystem = %AudioSystem


func __hard_dependencies() -> Array:
	return [sfx_system]


func _ready() -> void:
	__perform_validation()


## nullable but hard checked
func get_sfx_system() -> BaseWeaponSFXSystem:
	return sfx_system


## __LOGS
# region

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion
