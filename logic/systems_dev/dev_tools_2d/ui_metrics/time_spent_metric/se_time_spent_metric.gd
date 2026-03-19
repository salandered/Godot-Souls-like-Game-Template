@tool
class_name SETimeSpentMetric
extends BaseTimeSpentMetric


var _character: MechFighter


func _initialize_implementation() -> void:
	super._initialize_implementation()
	_char_type = DTS.CharacterType.SIMPLE_ENEMY
	
	_character = Groups.get_first_se_by_group(self )


func get_character() -> BaseStaticCharacter:
	return _character