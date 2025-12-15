@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name PingaBlade

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox
@onready var _visuals_: Node3D = %Visuals
@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent


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


func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


func _for_init_asp_container() -> BaseWeaponASPConfigContainer:
	return PingaASPConfigContainer.new()
	

func get_sad_container() -> WeaponSADContainer:
	return WeaponSADContainer.new()
