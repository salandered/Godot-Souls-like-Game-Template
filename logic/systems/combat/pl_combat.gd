@tool
extends BaseCombat
class_name PlayerCombat
@onready var _player: Princess = $".."
@onready var bones: PlayerBones = %bones


func initialise_implementation():
	if len(get_all_weapons()) > 1:
		__log_warn(true, "only 1 weapon is supported for PlayerCombat", "", "unpredictable. Amount:", len(get_all_weapons()))


func get_parent_node_of_weapons() -> Node3D:
	return bones


func is_player() -> bool:
	return true


func get_character() -> BaseCharacter:
	return _player


func pp_name() -> String:
	return "Player Combat"


## PLAYER SPECIFIC: WORK WITH INPUTS
# region

func contextualize(new_input: InputPackage, delta: float) -> InputPackage:
	# actualise_shieldshot(new_input)
	_translate_combat_actions(new_input, delta)
	# filter_with_resources(new_input)
	return new_input


## translates the input to basic states with the help of the current weapon
func _translate_combat_actions(new_input: InputPackage, delta: float):
	# todo: hard coded weapon!
	var weapon := get_weapon(WeaponNames.smith_sword)
	var _translated: Array = weapon.translate_combat_input_to_state(new_input.combat_actions)
	new_input.actions.append_array(_translated)

# endregion


# --------------------------

# region: Ideas
# static var _combat_inputs_priority: Dictionary = {
# 	CombatAction.light_attack_pressed: 1,
# 	CombatAction.light_attack_pressed_when_move: 2,
# 	CombatAction.heavy_attack_pressed: 3,
# }
# func filter_with_resources(input_: InputPackage):
# 	if resources.statuses.has("fatique"):
# 		input_.actions.erase("sprint")
# static func _priority_sort(a: String, b: String) -> bool:
# 	# 0 means lowest
# 	if _combat_inputs_priority[a] > _combat_inputs_priority[b]:
# 		return true
# 	else:
# 		return false
# endregion

# region: demo of magic abilities
# @export_group("spellbook")
# @export var shield_throw_charges: int = 1
# @export var max_shield_throw_charges: int = 1

# func actualise_shieldshot(new_input: InputPackage):
# 	if shield_throw_charges < 1:
# 		new_input.actions.erase("shield_throw")
# 	if shield_throw_charges == max_shield_throw_charges:
# 		new_input.actions.erase("shield_throw_reload")
# endregion
