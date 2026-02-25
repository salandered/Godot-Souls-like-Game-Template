@tool
class_name PingaBlade
extends PHEWeapon


@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox
@onready var _visuals_: Node3D = %Visuals
@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent


func initialise_implementation() -> void:
	PUSH_RIGID_BODIES_FORCE = 20.0


func validate_visuals() -> void:
	return # todo


func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_id() -> StringName:
	return WeaponID.big_pinga_blade


##

func get_spark_config() -> ParticlesConfig:
	return ParticlesConfig.new(15, 0.4)


## SFX


func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


func _for_init_asp_container() -> BaseWeaponASPConfigContainer:
	return PingaASPConfigContainer.new()
	

func get_sad_container() -> WeaponSADContainer:
	return WeaponSADContainer.new()
