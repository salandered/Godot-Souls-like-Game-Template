@tool
extends BaseTimeSpentMetric


var _character: Princess


func _initialise_implementation() -> void:
	_char_type = DVS.CharacterType.PLAYER

	var _r_players := get_tree().get_nodes_in_group(Groups.Chars.PLAYER)
	if len(_r_players) == 1 and _r_players[0] is Princess:
		_character = _r_players[0] as Princess


func get_character() -> BaseStaticCharacter:
	return _character
