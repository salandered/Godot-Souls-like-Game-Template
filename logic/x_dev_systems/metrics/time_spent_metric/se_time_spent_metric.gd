@tool
class_name SETimeSpentMetric
extends BaseTimeSpentMetric


var _character: MechFighter


func get_character() -> BaseStaticCharacter:
	return _character


func _initialise_implementation() -> void:
	super._initialise_implementation()
	_char_type = DVS.CharacterType.SIMPLE_ENEMY
	
	_character = Groups.get_first_se_by_group(self )
