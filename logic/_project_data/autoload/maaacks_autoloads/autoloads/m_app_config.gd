extends Node


## acting as an entry point for setting up the app state


func _ready() -> void:
	M_GlobalState.open()
	M_AppSettings.set_from_config_and_window(get_window())
	_apply_release_constraints()


func _apply_release_constraints() -> void:
	if not OS.is_debug_build():
		AudioServerUtil.mute_test_buses()
