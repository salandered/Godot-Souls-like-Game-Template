@abstract
class_name BaseNodeCharacterSystem
extends BaseNodeSystem


var __initialised: bool = false


@abstract func is_player() -> bool


# @abstract func initialise() -> void


# @abstract func get_hard_dependencies() -> Array[Node]

# @abstract func get_soft_dependencies() -> Array[Node]

func validate_hard_dependencies(list_: Array[Node]) -> bool:
	var _r: bool = true
	for item in list_:
		if not item:
			__log_error(pp.s("Dependency not set", item), "", "__initialised should be false")
			_r = false
	return _r