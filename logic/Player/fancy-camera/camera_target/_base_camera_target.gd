@abstract
class_name BaseCameraTarget
extends Node3D


## can be used as camera target or not
var _is_active: bool = true

var label: String = "not assigned"


@abstract func make_inactive() -> void


@abstract func make_active() -> void


@abstract func pp_name() -> String


func is_active() -> bool:
	return _is_active


## __LOG


func __log_warn(what: String, where: String, fallback: String, ...context: Array):
	print_.warn(false, what, where + " " + pp_name(), fallback, pp.s(pp.list_(context), "| label:", label))


func __log_(...parts: Array):
	print_.prefix(pp_name(), pp.s(pp.list_(parts), "| label:", label))
