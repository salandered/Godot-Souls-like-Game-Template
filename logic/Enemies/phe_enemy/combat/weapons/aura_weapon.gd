@tool
@icon("res://-assets-/x_misc/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name AuraWeapon

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox


func initialise() -> void:
	pass


func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_name() -> String:
	return WeaponNames.bg_aura_weapon


func get_weapon_visuals() -> MeshInstance3D:
	return null
