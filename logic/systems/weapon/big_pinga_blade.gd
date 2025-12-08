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

func get_weapon_pp_name() -> String:
	return WeaponNames.big_pinga_blade


func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_



## SFX

func get_weapon_audio_system() -> BaseWeaponAudioSystem:
	return weapon_sfx.get_audio_system()


const WEAPON_WHOOSH = preload("uid://qufmydm4eeq4")
const SWORD_HIT_BONES = preload("uid://g4dtkcleinh8")

func set_whoosh_weapon_stream():
	weapon_sfx.set_whoosh_weapon_stream(WEAPON_WHOOSH)

func set_hit_weapon_stream():
	weapon_sfx.set_hit_weapon_stream(SWORD_HIT_BONES)
