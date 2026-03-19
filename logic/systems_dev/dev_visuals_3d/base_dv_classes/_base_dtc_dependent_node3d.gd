@tool
@icon("uid://sboavald7fvc")

@abstract
class_name BaseDTCDependentNode3D
extends Node3DSystem


func _ready() -> void:
	add_to_group(Groups.Dev.DEV_TOOLS)
	visible = false


@abstract func initialize() -> void

##

func pp_name() -> String:
	return "🎨DV|" + super.pp_name()


func __LOG_B() -> bool:
	return false
