extends Node3D
class_name WeaponSFX

@onready var sfx_system: BaseWeaponSFXSystem = %AudioSystem


func _ready() -> void:
	assert(sfx_system)


## not nullable
func get_sfx_system() -> BaseWeaponSFXSystem:
	return sfx_system


func set_whoosh_weapon_stream(stream: AudioStream) -> void:
	sfx_system.set_whoosh_weapon_stream(stream)


func set_hit_weapon_stream(stream: AudioStream) -> void:
	sfx_system.set_hit_weapon_stream(stream)
