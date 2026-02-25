extends Node


## acting as an entry point for setting up the app state


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#481317"))
	M_GlobalState.open()
	M_AppSettings.set_from_config_and_window(get_window())
	_apply_release_constraints()


func _apply_release_constraints() -> void:
	if eu.is_release():
		AudioServerUtil.mute_test_buses()
