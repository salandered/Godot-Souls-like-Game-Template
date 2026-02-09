@tool
class_name FighterVArmWeapon
extends FighterArmWeapon


@onready var v_arm_weapon_hurt_box: WeaponHurtBox = %VArmWeaponHurtBox
@onready var v_weapon_sfx_parent: WeaponSFXParent = %VWeaponSFXParent


func get_weapon_hurt_box() -> WeaponHurtBox:
	return v_arm_weapon_hurt_box

func get_weapon_id() -> String:
	return WeaponID.fighter_v_arm


## SFX


func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return v_weapon_sfx_parent
