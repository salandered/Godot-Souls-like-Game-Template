@tool
extends BasePlayerWeapon
class_name SmithSword

@onready var _weapon_hurt_box_: WeaponHurtBox = $WeaponHurtBox
@onready var _visuals_: Node3D = $Visuals


func initialise() -> void:
	var mesh: MeshInstance3D = _visuals_.get_child(0)
	assert(mesh and mesh is MeshInstance3D)
	
	_input_action_to_state = {
		# CombatAction.light_attack_pressed: PS.axe_slice_1,
		CombatAction.light_attack_pressed: PS.sword_slash_1,
		# CombatAction.light_attack_pressed_when_move: PS.attack_from_run
	}
	
func get_weapon_hurt_box() -> WeaponHurtBox:
	return _weapon_hurt_box_

func get_weapon_name() -> String:
	return WeaponNames.smith_sword


func get_weapon_visuals() -> MeshInstance3D:
	return _visuals_
