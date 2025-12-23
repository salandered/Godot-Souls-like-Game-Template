@tool
@icon("res://-assets-/x_icons/red/icon_sword.png")
extends PHEWeapon
class_name AuraWeapon

@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent

@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox


func initialise_implementation() -> void:
	pass


func validate_visuals():
	return

func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_id() -> String:
	return WeaponID.bg_aura_weapon


## SFX


func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


func _for_init_asp_container() -> BaseWeaponASPConfigContainer:
	return AuraASPConfigContainer.new()


func get_sad_container() -> WeaponSADContainer:
	return AuraWeaponSADContainer.new()
