@tool

@abstract
class_name BasePlayerWeapon
extends BaseWeapon


## E.g: Sword maps 'light attack pressed' to slash, while staff to spell.
## _input_action_to_state = {
## 	CombatAction.light_attack_pressed: PS.longsword_1
## }
## NOTE: specific to player only. Is here for now for simplicity.
var _input_action_to_state: Dictionary[String, String] = {} # input actions to states


func is_player() -> bool:
	return true


func translate_combat_input_to_state(combat_actions: Array) -> Array:
	var _translated: Array[String] = []
	
	for input_action in combat_actions:
		if u.safe_has_key(_input_action_to_state, input_action, WarnLevel.SILENT):
			_translated.append(_input_action_to_state[input_action])

	if not combat_actions.is_empty() and _translated.is_empty():
		__log_error(pp.s("BaseWeapon", get_weapon_id(), "has no map for actions", combat_actions, "mapping", _input_action_to_state))
	# if not _translated.is_empty():
		# print_.fight("PlCombat", pp.s("actions ", combat_actions, "translatedToSt", _translated))
	return _translated
