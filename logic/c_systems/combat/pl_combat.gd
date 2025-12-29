@tool
extends BaseCombat
class_name PlayerCombat
@onready var _player: Princess = $".."
@onready var bones: PlayerBones = %bones
@onready var weapon_switcher: WeaponSwitcher = %WeaponSwitcher


func initialise_implementation():
	weapon_switcher.initialise(_player, self)


func __hard_validate() -> bool:
	var _r: bool = true
	if len(_get_all_registered_weapons()) == 0:
		__log_error("currently at least one weapon is expected for player", "", "")
		_r = false
	for weapon in _get_all_registered_weapons():
		if weapon is not BasePlayerWeapon:
			__log_error("weapon is not BasePlayerWeapon", "", "", weapon)
			_r = false
	if len(get_active_weapon_ids()) != 1:
		__log_error("currently 1 active weapon is expected for player", "", "", len(get_active_weapon_ids()))
		_r = false
	return _r


func get_parent_node_of_weapons() -> Node3D:
	return bones


func is_player() -> bool:
	return true


func get_character() -> BaseCharacter:
	return _player


## PLAYER SPECIFIC: WORK WITH INPUTS
# region

func contextualize(new_input: InputPackage, delta: float) -> InputPackage:
	# actualise_shieldshot(new_input)
	_translate_combat_actions(new_input, delta)
	# filter_with_resources(new_input)
	return new_input


## translates the input to basic states with the help of the active weapon
func _translate_combat_actions(new_input: InputPackage, delta: float):
	var weapons := get_all_active_weapons()
	if len(weapons) == 0:
		return
	# we take first one because for player only one can be active currently
	var weapon: BasePlayerWeapon = weapons[0]
	var _translated := weapon.translate_combat_input_to_state(new_input.combat_actions)
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
