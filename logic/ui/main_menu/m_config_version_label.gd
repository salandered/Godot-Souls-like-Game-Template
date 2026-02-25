@tool
class_name M_ConfigVersionLabel
extends Label


## Displays the value of `application/config/version`, set in project settings


@export var version_prefix: String = "v"

const NO_VERSION_STRING: String = "0.0.0"


func update_version_label() -> void:
	var config_version: String = ProjectSettings.get_setting(PropC.APPLICATION_CONFIG_VERSION, NO_VERSION_STRING)
	if config_version.is_empty():
		config_version = NO_VERSION_STRING
	text = version_prefix + config_version


func _ready() -> void:
	update_version_label()
