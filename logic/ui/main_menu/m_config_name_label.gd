@tool
class_name ConfigNameLabel
extends Label
## Displays the value of `application/config/name`, set in project settings.

const NO_NAME_STRING: String = "Title"

@export var auto_update: bool = true


func update_name_label() -> void:
	var config_name: String = ProjectSettings.get_setting("application/config/name", NO_NAME_STRING)
	if config_name.is_empty():
		config_name = NO_NAME_STRING
	text = config_name

func _ready() -> void:
	if auto_update:
		update_name_label()
