@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name PingaBlade

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox
@onready var _visuals_: Node3D = %Visuals


func initialise() -> void:
	var mesh: MeshInstance3D = _visuals_.get_child(0)
	assert(mesh and mesh is MeshInstance3D)


func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_name() -> String:
	return WeaponNames.big_pinga_blade


func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_
