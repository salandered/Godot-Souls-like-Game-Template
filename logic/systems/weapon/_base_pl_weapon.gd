@tool

@abstract
class_name BasePlayerWeapon
extends BaseWeapon


## E.g: Sword maps 'light attack pressed' to slash, while staff to spell.
## _input_action_to_state = {
## 	CombatAction.light_attack_pressed: PS.longsword_1
## }
var _input_action_to_state: Dictionary[StringName, StringName] = {} # input actions to states


func is_player() -> bool:
	return true


func translate_combat_input_to_state(combat_actions: Array[StringName]) -> Array[StringName]:
	var _translated: Array[StringName] = []
	
	for input_action in combat_actions:
		if DictUtils.safe_has_key(_input_action_to_state, input_action, WL.SILENT):
			_translated.append(_input_action_to_state[input_action])

	if not combat_actions.is_empty() and _translated.is_empty():
		__log_error(pp.s("BaseWeapon", get_weapon_id(), "has no map for actions", combat_actions, "mapping", _input_action_to_state))
	# if not _translated.is_empty():
		# __log_("actions ", combat_actions, "translatedToSt", _translated)
	return _translated
