class_name FighterHArmWeapon
extends FighterArmWeapon


@onready var h_arm_weapon_hurt_box: WeaponHurtBox = %HArmWeaponHurtBox
@onready var h_weapon_sfx_parent: WeaponSFXParent = %HWeaponSFXParent


func get_weapon_hurt_box() -> WeaponHurtBox:
	return h_arm_weapon_hurt_box

func get_weapon_id() -> StringName:
	return WeaponID.fighter_h_arm


## SFX


func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return h_weapon_sfx_parent
