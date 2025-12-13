@tool
extends BasePlayerWeapon
class_name PlPingaBlade


@onready var _weapon_hurt_box_: WeaponHurtBox = %WeaponHurtBox
@onready var _visuals_: Node3D = %Visuals
@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent


## SFX


func initialise_implementation() -> void:
	var mesh: MeshInstance3D = _visuals_.get_child(0)
	if not mesh or mesh is not MeshInstance3D:
		__log_error("if not mesh or mesh is not MeshInstance3D")
	
	_input_action_to_state = {
		# CombatAction.light_attack_pressed: PS.axe_slice_1,
		CombatAction.light_attack_pressed: PS.sword_slash_1,
		# CombatAction.light_attack_pressed_when_move: PS.attack_from_run
	}
	
func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_id() -> String:
	return WeaponID.pl_pinga_blade



func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_


## SFX

func _for_init_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


func _for_init_asp_container() -> BaseWeaponASPConfigContainer:
	return PingaASPConfigContainer.new()
	

func get_sad_container() -> WeaponSADContainer:
	return WeaponSADContainer.new()

# func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream:
# 	for material in hit_sounds.keys():
# 		if target.is_in_group(material):
# 			return hit_sounds[material]
# 	return hit_sounds.get("Default", null)
