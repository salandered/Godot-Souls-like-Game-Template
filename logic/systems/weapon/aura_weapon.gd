@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name AuraWeapon

@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox


func initialise_implementation() -> void:
	pass


func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_id() -> String:
	return WeaponID.bg_aura_weapon


func get_weapon_visuals() -> MeshInstance3D:
	return null

## SFX

const WEAPON_WHOOSH = preload("uid://qufmydm4eeq4")
const SWORD_HIT_BONES = preload("uid://g4dtkcleinh8")


func _get_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


func _get_weapon_whoosh_stream() -> AudioStream:
	return WEAPON_WHOOSH

func _get_hit_weapon_stream() -> AudioStream:
	return SWORD_HIT_BONES
