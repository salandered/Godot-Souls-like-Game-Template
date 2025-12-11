@tool
extends BasePlayerWeapon
class_name SmithSword

@onready var _weapon_hurt_box_: WeaponHurtBox = $WeaponHurtBox
@onready var _visuals_: Node3D = $Visuals

@onready var weapon_sfx: WeaponSFXParent = $WeaponSFXParent


var hit_sounds: Dictionary = {
	# "Material:Wood": preload("res://.../hit_wood.wav"),
	# "Material:Stone": preload("res://.../hit_stone.wav"),
	# "Material:Flesh": preload("res://.../hit_flesh.wav"),
	# "Default": preload("res://.../hit_metal_default.wav")
}

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
	return WeaponID.smith_sword


func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_


## SFX


func _get_weapon_sfx_parent() -> WeaponSFXParent:
	return weapon_sfx


# func get_sfx_hit_stream_for_target(target: Node3D) -> AudioStream:
# 	for material in hit_sounds.keys():
# 		if target.is_in_group(material):
# 			return hit_sounds[material]
# 	return hit_sounds.get("Default", null)
