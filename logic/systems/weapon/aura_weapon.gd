@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name AuraWeapon

@onready var weapon_sfx: WeaponSFX = $WeaponSFX

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox


func initialise_implementation() -> void:
	pass


func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_pp_name() -> String:
	return WeaponNames.bg_aura_weapon


func get_weapon_visuals() -> MeshInstance3D:
	return null

## SFX

func get_weapon_audio_system() -> BaseWeaponAudioSystem:
	return weapon_sfx.get_audio_system()


const WEAPON_WHOOSH = preload("uid://qufmydm4eeq4")
const SWORD_HIT_BONES = preload("uid://g4dtkcleinh8")

func set_whoosh_weapon_stream():
	weapon_sfx.set_whoosh_weapon_stream(WEAPON_WHOOSH)

func set_hit_weapon_stream():
	weapon_sfx.set_hit_weapon_stream(SWORD_HIT_BONES)
