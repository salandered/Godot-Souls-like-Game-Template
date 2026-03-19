@abstract

## TODO: make implementations more similar
class_name BaseLookAtManager
extends NodeSystem


var _target_marker: LookAtCharacterMarker
var _my_marker: LookAtCharacterMarker


@abstract func initialize(target_marker_: LookAtCharacterMarker, my_marker_: LookAtCharacterMarker) -> void


func __hard_dependencies() -> Array:
	return [
		_my_marker
	]