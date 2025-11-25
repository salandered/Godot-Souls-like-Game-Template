extends Node

func _ready() -> void:
	M_GlobalState.open()
	M_AppSettings.set_from_config_and_window(get_window())
