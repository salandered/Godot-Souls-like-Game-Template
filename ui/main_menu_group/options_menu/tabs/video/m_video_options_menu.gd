class_name M_VideoOptionsMenu
extends Control

# Logic to disable the resolution dropdown when the game is in fullscreen. 
# Synchronization: keeps UI in sync with the game's state. 
# E.g, if you manually resize the game window, script detects this and 
# automatically updates the value shown in the resolution dropdown

func _preselect_resolution(window: Window) -> void:
	%ResolutionControl.value = window.size

func _update_resolution_options_enabled(window: Window) -> void:
	if M_AppSettings.is_fullscreen(window):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for fullscreen"
	else:
		%ResolutionControl.editable = true
		%ResolutionControl.tooltip_text = "Select a screen size"

func _update_ui(window: Window) -> void:
	%DisplayModeControl.value = window.mode
	_preselect_resolution(window)
	%VSyncControl.value = M_AppSettings.get_vsync(window)
	_update_resolution_options_enabled(window)
	%FPSLimitControl.value = Engine.max_fps

func _ready() -> void:
	var window: Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _on_display_mode_control_setting_changed(value) -> void:
	var window: Window = get_window()
	M_AppSettings.set_display_mode(value, window)
	_update_resolution_options_enabled(window)

func _on_resolution_control_setting_changed(value) -> void:
	M_AppSettings.set_resolution(value, get_window(), false)

func _on_v_sync_control_setting_changed(value) -> void:
	M_AppSettings.set_vsync(value, get_window())


func _on_fps_limit_control_setting_changed(value: Variant) -> void:
	M_AppSettings.set_fps_limit(value)
