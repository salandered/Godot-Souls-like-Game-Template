@tool
class_name PlTimeSpentMetric
extends BaseTimeSpentMetric

@export var ts_curr_action_label: Label

var _character: Princess


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		ts_curr_action_label
	]


func get_character() -> BaseStaticCharacter:
	return _character


func _initialise_implementation() -> void:
	super._initialise_implementation()
	_update_metric(ts_curr_action_label, DEF_NO_VALUE)
	_char_type = DVS.CharacterType.PLAYER

	var _r_players := get_tree().get_nodes_in_group(Groups.Chars.PLAYER)
	if len(_r_players) == 1 and _r_players[0] is Princess:
		_character = _r_players[0] as Princess


func _process_imp(delta: float):
	var ats := get_time_spent_action()
	_update_metric(ts_curr_action_label, ats)
	return


func get_time_spent_action() -> float:
	if not _character: return DEF_NO_VALUE
	var psm := _character.player_sm
	if not psm: return DEF_NO_VALUE
	var curr_action := psm.get_curr_action()
	if not curr_action: return DEF_NO_VALUE
	var ts := curr_action.get_actual_time_spent()
	return ts
