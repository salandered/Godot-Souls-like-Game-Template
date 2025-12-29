@tool
class_name SmallPingaBlade
extends BasePlayerWeapon


@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox
@onready var _visuals_: Node3D = %Visuals
@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent


func initialise_implementation() -> void:
	_input_action_to_state = {
		CombatAction.light_attack_pressed: PS.axe_slice_1,
		CombatAction.heavy_attack_pressed: PS.axe_slice_3,
		# CombatAction.light_attack_pressed_when_move: PS.attack_from_run
	}


func validate_visuals() -> void:
	return # todo

func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_id() -> String:
	return WeaponID.small_pinga_blade

##

func get_spark_config() -> ParticlesConfig:
	return ParticlesConfig.new(20, 1.0)


## SFX


func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


func _for_init_asp_container() -> BaseWeaponASPConfigContainer:
	return PingaASPConfigContainer.new()
	

func get_sad_container() -> WeaponSADContainer:
	return WeaponSADContainer.new()
