class_name M_VideoOptionsMenu
extends ControlLogger

# Logic to disable the resolution dropdown when the game is in fullscreen. 
# Synchronization: keeps UI in sync with the game's state. 
# E.g, if you manually resize the game window, script detects this and 
# automatically updates the value shown in the resolution dropdown


func _ready() -> void:
	var window: Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))


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
	%UIScaleControl.value = M_AppSettings.get_ui_scale(window)
	%AntiAliasingControl.value = M_AppSettings.get_msaa_3d(window)
	%BrightnessControl.value = M_AppSettings.get_brightness()
	%VolumetricFogControl.value = M_AppSettings.get_volumetric_fog()
	%ShadowControl.value = M_AppSettings.get_shadow_mode()
	

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


func _on_anti_aliasing_control_setting_changed(value: Variant) -> void:
	M_AppSettings.set_msaa_3d(value, get_window())


func _on_ui_scale_setting_changed(value: Variant) -> void:
	M_AppSettings.set_ui_scale(value, get_window())


func _on_brightness_control_setting_changed(value: Variant) -> void:
	M_AppSettings.set_brightness(value, get_window())


func _on_volumetric_fog_control_setting_changed(value: Variant) -> void:
	M_AppSettings.set_volumetric_fog(value)


func _on_shadow_control_setting_changed(value: Variant) -> void:
	M_AppSettings.set_shadow_mode(value) # Replace with function body.


## Reset

func _on_reset_button_pressed() -> void:
	var window: Window = get_window()
	
	# if %DisplayModeControl.default_value is int:
	# 	M_AppSettings.set_display_mode(%DisplayModeControl.default_value, window)
	# else:
	# 	__log_warn("reset problem", "DisplayModeControl")

	# if %ResolutionControl.default_value is Vector2i:
	# 	M_AppSettings.set_resolution(%ResolutionControl.default_value, window, false)
	# else:
	# 	__log_warn("reset problem", "ResolutionControl")

	if %VSyncControl.default_value is int:
		M_AppSettings.set_vsync(%VSyncControl.default_value, window)
	else:
		__log_warn("reset problem", "VSyncControl")

	M_AppSettings.set_fps_limit(60)

	if %AntiAliasingControl.default_value is int:
		M_AppSettings.set_msaa_3d(%AntiAliasingControl.default_value, window)
	else:
		__log_warn("reset problem", "AntiAliasingControl")

	M_AppSettings.set_ui_scale(1.0, window)

	M_AppSettings.set_brightness(1.0, window)
	
	M_AppSettings.set_volumetric_fog(true)

	M_AppSettings.set_shadow_mode(0)

	
	_update_ui(window)
