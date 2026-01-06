@abstract
class_name CharacterSFXSystem
extends BaseSFXSystem


const character_additional_data_key := "character"


var _character: BaseCharacter


func __hard_dependencies() -> Array[Object]:
	return [
		_character
	]


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	_character = u.safe_get_dict_key(additional_data, character_additional_data_key, null)


## non nullable
func get_character() -> BaseCharacter:
	return _character


# endregion


## __LOG

func pp_name() -> String:
	var prefix = get_character().pp_name() if get_character() else ""
	return pp.s(prefix, u.construct_obj_pp_name(self))


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0
