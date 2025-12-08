extends Node3D
class_name WeaponSFX

@onready var audio_system: BaseWeaponAudioSystem = %AudioSystem


func get_audio_system() -> BaseWeaponAudioSystem:
	return audio_system


func set_whoosh_weapon_stream(stream: AudioStream) -> void:
	audio_system.set_whoosh_weapon_stream(stream)


func set_hit_weapon_stream(stream: AudioStream) -> void:
	audio_system.set_hit_weapon_stream(stream)
