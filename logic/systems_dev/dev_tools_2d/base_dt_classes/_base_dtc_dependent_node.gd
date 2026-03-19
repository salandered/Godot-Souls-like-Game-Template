@tool
@icon("uid://sboavald7fvc")

@abstract
class_name BaseDTCDependentNode
extends NodeSystem


func _ready() -> void:
	add_to_group(Groups.Dev.DEV_TOOLS)
	reset_visuals()


@abstract func initialize() -> void


@abstract func reset_visuals() -> void


## LOGS

func pp_name() -> String:
	return "🖌️DV|" + super.pp_name()


func __LOG_B() -> bool:
	return true