@tool
class_name M_ConfigNameLabel
extends Label


## Displays the value of `application/config/name`, set in project settings


@export var auto_update: bool = true

const NO_NAME_STRING: String = "Title"


func update_name_label() -> void:
	var config_name: String = ProjectSettings.get_setting(PropC.APPLICATION_CONFIG_NAME, NO_NAME_STRING)
	if config_name.is_empty():
		config_name = NO_NAME_STRING
	text = config_name


func _ready() -> void:
	if auto_update:
		update_name_label()
