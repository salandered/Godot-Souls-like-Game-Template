@abstract
class_name BaseCameraTarget
extends Node3DSystem


@export var Y_ui_marker_shift: float = 0.0


## can be used as camera target or not
var _is_active: bool = true

var label: String = "not assigned"


@abstract func make_inactive() -> void


@abstract func make_active() -> void


func is_active() -> bool:
	return _is_active
