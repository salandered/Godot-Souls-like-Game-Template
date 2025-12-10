@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name PingaBlade

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox
@onready var _visuals_: Node3D = %Visuals
@onready var weapon_sfx: WeaponSFX = $WeaponSFX


func initialise_implementation() -> void:
	var mesh: MeshInstance3D = _visuals_.get_child(0)
	assert(mesh and mesh is MeshInstance3D)


func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_id() -> String:
	return WeaponID.big_pinga_blade


func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_


## SFX


const WEAPON_WHOOSH = preload("uid://qufmydm4eeq4")
const SWORD_HIT_BONES = preload("uid://g4dtkcleinh8")


func _get_weapon_sfx_parent() -> WeaponSFX:
	return weapon_sfx


func _get_weapon_whoosh_stream() -> AudioStream:
	return WEAPON_WHOOSH

func _get_hit_weapon_stream() -> AudioStream:
	return SWORD_HIT_BONES
