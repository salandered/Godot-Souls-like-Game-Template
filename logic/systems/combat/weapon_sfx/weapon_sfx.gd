extends BaseNode3DSystem
class_name WeaponSFXParent


@onready var sfx_system: BaseWeaponSFXSystem = %AudioSystem


func get_hard_dependencies() -> Array[Object]:
	return [sfx_system]


func _ready() -> void:
	__validate_deps_set_init()


## nullable but hard checked
func get_sfx_system() -> BaseWeaponSFXSystem:
	return sfx_system


func set_whoosh_weapon_stream(stream: AudioStream) -> void:
	if __could_not_initialised():
		return
	sfx_system.set_whoosh_weapon_stream(stream)


func set_hit_weapon_stream(stream: AudioStream) -> void:
	if __could_not_initialised():
		return
	sfx_system.set_hit_weapon_stream(stream)


## __LOGS
# region

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# endregion
