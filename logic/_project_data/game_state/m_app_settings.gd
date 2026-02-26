class_name M_AppSettings
extends NodeStaticLogger


## == ✴️ from Maaacks template == 
## == How much changed: Added lots of options ==
## TODO: Changed a lot, but original architecture does not fit the project, needs refactor
## 

const shadow_mode_number_to_val: Dictionary[int, DirectionalLight3D.ShadowMode] = {
	0: DirectionalLight3D.ShadowMode.SHADOW_PARALLEL_4_SPLITS,
	1: DirectionalLight3D.ShadowMode.SHADOW_PARALLEL_2_SPLITS,
	2: DirectionalLight3D.ShadowMode.SHADOW_ORTHOGONAL,
	3: DirectionalLight3D.ShadowMode.SHADOW_PARALLEL_4_SPLITS,
}

## Interface to read/write general application settings through [M_PlayerConfig].

const INPUT_SECTION = &'InputSettings'
const AUDIO_SECTION = &'AudioSettings'
const VIDEO_SECTION = &'VideoSettings'
const GAME_SECTION = &'GameSettings'
const APPLICATION_SECTION = &'ApplicationSettings'
const CUSTOM_SECTION = &'CustomSettings'


const BRIGHTNESS = &'Brightness'
const VOLUMETRIC_FOG = &'VolumetricFog'
const SHADOW_MODE = &'Shadows'
const FPS_LIMIT = &'FpsLimit'
const DISPLAY_MODE = &'DisplayMode'
const SCREEN_RESOLUTION = &'ScreenResolution'
const V_SYNC = &'V-Sync'
const UI_SCALE = &'UIScale'
const MSAA_3D = &'AntiAliasing'
const X_MOUSE_SENSE = &'XMouseSense'
const Y_MOUSE_SENSE = &'YMouseSense'
const MUTE_SETTING = &'Mute'
const MASTER_BUS_INDEX = 0
const SYSTEM_BUS_NAME_PREFIX = "_"


## A global, static class that acts as the central hub for managing all application settings.
## It provides a high-level interface for other parts of the game to read and write settings for Input, Audio, and Video.
## Uses a 'M_PlayerConfig' class to handle the actual file I/O.
## Its main responsibilities include:
## - Saving and loading custom user keybindings to the config file.
## - Managing and persisting audio bus volumes and the master mute state. 
## - Handling video settings like fullscreen, resolution, and V-Sync.
## - Applying all saved settings when the game starts.

# region: Input

static var default_action_events: Dictionary
static var initial_bus_volumes: Array


static func get_config_input_events(action_name: String, default = null) -> Array:
	return M_PlayerConfig.get_config(INPUT_SECTION, action_name, default)


static func set_config_input_events(action_name: String, inputs: Array) -> void:
	M_PlayerConfig.set_config(INPUT_SECTION, action_name, inputs)


static func _clear_config_input_events() -> void:
	M_PlayerConfig.erase_section(INPUT_SECTION)


static func remove_action_input_event(action_name: String, input_event: InputEvent) -> void:
	InputMap.action_erase_event(action_name, input_event)
	var action_events: Array[InputEvent] = InputMap.action_get_events(action_name)
	var config_events: Array = get_config_input_events(action_name, action_events)
	config_events.erase(input_event)
	set_config_input_events(action_name, config_events)


static func set_input_from_config(action_name: String) -> void:
	var action_events: Array[InputEvent] = InputMap.action_get_events(action_name)
	var config_events = get_config_input_events(action_name, action_events)
	if config_events == action_events:
		return
	if config_events.is_empty():
		M_PlayerConfig.erase_section_key(INPUT_SECTION, action_name)
		return
	InputMap.action_erase_events(action_name)
	for config_event in config_events:
		if config_event not in action_events:
			InputMap.action_add_event(action_name, config_event)

static func _get_action_names() -> Array[StringName]:
	return InputMap.get_actions()

static func _get_custom_action_names() -> Array[StringName]:
	var callable_filter := func(action_name): return not (action_name.begins_with("ui_") or action_name.begins_with("spatial_editor"))
	var action_list := _get_action_names()
	return action_list.filter(callable_filter)

static func get_action_names(built_in_actions: bool = false) -> Array[StringName]:
	if built_in_actions:
		return _get_action_names()
	else:
		return _get_custom_action_names()

static func reset_to_default_inputs() -> void:
	_clear_config_input_events()
	for action_name in default_action_events:
		InputMap.action_erase_events(action_name)
		var input_events = default_action_events[action_name]
		for input_event in input_events:
			InputMap.action_add_event(action_name, input_event)

static func set_default_inputs() -> void:
	var action_list: Array[StringName] = _get_action_names()
	for action_name in action_list:
		default_action_events[action_name] = InputMap.action_get_events(action_name)

static func set_inputs_from_config() -> void:
	var action_list: Array[StringName] = _get_action_names()
	for action_name in action_list:
		set_input_from_config(action_name)

# endregion

# region: Audio

static func get_bus_volume(bus_index: int) -> float:
	var initial_linear = 1.0
	if initial_bus_volumes.size() > bus_index:
		initial_linear = initial_bus_volumes[bus_index]
	var linear = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	linear /= initial_linear
	return linear

static func set_bus_volume(bus_index: int, linear: float) -> void:
	var initial_linear = 1.0
	if initial_bus_volumes.size() > bus_index:
		initial_linear = initial_bus_volumes[bus_index]
	linear *= initial_linear
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear))


static func is_muted() -> bool:
	return AudioServer.is_bus_mute(MASTER_BUS_INDEX)


static func set_mute(mute_flag: bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS_INDEX, mute_flag)


static func get_audio_bus_name(bus_iter: int) -> String:
	return AudioServer.get_bus_name(bus_iter)


static func set_audio_from_config() -> void:
	for bus_iter in AudioServer.bus_count:
		var bus_key: String = get_audio_bus_name(bus_iter).to_pascal_case()
		var bus_volume: float = get_bus_volume(bus_iter)
		initial_bus_volumes.append(bus_volume)
		bus_volume = M_PlayerConfig.get_config(AUDIO_SECTION, bus_key, bus_volume)
		if is_nan(bus_volume):
			bus_volume = 1.0
			M_PlayerConfig.set_config(AUDIO_SECTION, bus_key, bus_volume)
		set_bus_volume(bus_iter, bus_volume)
	var mute_audio_flag: bool = is_muted()
	mute_audio_flag = M_PlayerConfig.get_config(AUDIO_SECTION, MUTE_SETTING, mute_audio_flag)
	set_mute(mute_audio_flag)

# endregion

# region: Video

static func set_display_mode(mode: int, window: Window) -> void:
	window.mode = mode as Window.Mode

static func set_resolution(value: Vector2i, window: Window, update_config: bool = true) -> void:
	if value.x == 0 or value.y == 0:
		return
	window.size = value
	if update_config:
		M_PlayerConfig.set_config(VIDEO_SECTION, SCREEN_RESOLUTION, value)


static func is_fullscreen(window: Window) -> bool:
	return (window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (window.mode == Window.MODE_FULLSCREEN)

static func get_resolution(window: Window) -> Vector2i:
	var current_resolution: Vector2i = window.size
	return M_PlayerConfig.get_config(VIDEO_SECTION, SCREEN_RESOLUTION, current_resolution)

static func _on_window_size_changed(window: Window) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, SCREEN_RESOLUTION, window.size)

static func _set_display_mode_from_config(window: Window) -> void:
	var current_mode: int = 3
	# var current_mode: int = window.mode
	var saved_mode: int = M_PlayerConfig.get_config(VIDEO_SECTION, DISPLAY_MODE, current_mode)
	set_display_mode(saved_mode, window)

static func set_vsync(vsync_mode: DisplayServer.VSyncMode, window: Window = null) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, V_SYNC, vsync_mode)
	var window_id: int = 0
	if window:
		window_id = window.get_window_id()
	DisplayServer.window_set_vsync_mode(vsync_mode, window_id)

static func get_vsync(window: Window = null) -> DisplayServer.VSyncMode:
	var window_id: int = 0
	if window:
		window_id = window.get_window_id()
	var vsync_mode = DisplayServer.window_get_vsync_mode(window_id)
	return vsync_mode

static func _set_v_sync_from_config(window: Window) -> DisplayServer.VSyncMode:
	var vsync := DisplayServer.VSyncMode.VSYNC_ENABLED
	vsync = M_PlayerConfig.get_config(VIDEO_SECTION, V_SYNC, vsync)
	set_vsync(vsync)
	return vsync

static func _set_fps_limit_from_config() -> void:
	var default_limit: int = Engine.max_fps
	var saved_limit: int = M_PlayerConfig.get_config(VIDEO_SECTION, FPS_LIMIT, default_limit)
	set_fps_limit(saved_limit)

static func set_fps_limit(limit: int) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, FPS_LIMIT, limit)
	Engine.max_fps = limit

static func set_ui_scale(scale: float, window: Window) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, UI_SCALE, scale)
	window.get_tree().root.content_scale_factor = scale

static func get_ui_scale(window: Window) -> float:
	return window.get_tree().root.content_scale_factor

static func _set_ui_scale_from_config(window: Window) -> void:
	var default_scale: float = 1.0
	# var dpi_scale = DisplayServer.screen_get_scale()
	# if dpi_scale > 1.0:
		# default_scale = dpi_scale
	
	var saved_scale: float = M_PlayerConfig.get_config(VIDEO_SECTION, UI_SCALE, default_scale)
	set_ui_scale(saved_scale, window)


static func set_msaa_3d(msaa_mode: Viewport.MSAA, window: Window) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, MSAA_3D, msaa_mode)
	window.get_viewport().msaa_3d = msaa_mode

static func get_msaa_3d(window: Window) -> Viewport.MSAA:
	return window.get_viewport().msaa_3d


static func _set_msaa_from_config(window: Window) -> void:
	var default_msaa: Viewport.MSAA = Viewport.MSAA.MSAA_2X
	var saved_msaa: Viewport.MSAA = M_PlayerConfig.get_config(VIDEO_SECTION, MSAA_3D, default_msaa)
	set_msaa_3d(saved_msaa, window)

static func set_video_from_config(window: Window) -> void:
	window.size_changed.connect(_on_window_size_changed.bind(window))
	_set_display_mode_from_config(window)
	if not is_fullscreen(window):
		var current_resolution: Vector2i = get_resolution(window)
		set_resolution(current_resolution, window)
	_set_v_sync_from_config(window)
	_set_fps_limit_from_config()
	_set_ui_scale_from_config(window)
	_set_msaa_from_config(window)
	_set_brightness_from_config(window)
	_set_volumetric_fog_from_config()
	_set_shadow_mode_from_config()

# endregion


# region --- BRIGHTNESS / EXPOSURE ---


static func set_brightness(value: float, window: Window) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, BRIGHTNESS, value)
	SigUtils.safe_emit_no_payload(GlobalSignal.SIG_update_video_settings_for_level)


static func get_brightness() -> float:
	return M_PlayerConfig.get_config(VIDEO_SECTION, BRIGHTNESS, 1.0)


static func _set_brightness_from_config(window: Window) -> void:
	var default_val: float = 1.0
	var saved_val: float = M_PlayerConfig.get_config(VIDEO_SECTION, BRIGHTNESS, default_val)
	set_brightness(saved_val, window)


# endregion

##

static func set_volumetric_fog(value: bool) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, VOLUMETRIC_FOG, value)
	SigUtils.safe_emit_no_payload(GlobalSignal.SIG_update_video_settings_for_level)


static func get_volumetric_fog() -> bool:
	return M_PlayerConfig.get_config(VIDEO_SECTION, VOLUMETRIC_FOG, true)

static func _set_volumetric_fog_from_config() -> void:
	var default_val: bool = true
	var saved_val: bool = M_PlayerConfig.get_config(VIDEO_SECTION, VOLUMETRIC_FOG, default_val)
	set_volumetric_fog(saved_val)


static func set_shadow_mode(value: int) -> void:
	M_PlayerConfig.set_config(VIDEO_SECTION, SHADOW_MODE, value)
	SigUtils.safe_emit_no_payload(GlobalSignal.SIG_update_video_settings_for_level)


static func get_shadow_mode() -> int:
	return M_PlayerConfig.get_config(VIDEO_SECTION, SHADOW_MODE, true)

static func _set_shadow_mode_from_config() -> void:
	var default_val: int = 0
	var saved_val: int = M_PlayerConfig.get_config(VIDEO_SECTION, SHADOW_MODE, default_val)
	set_shadow_mode(saved_val)


## controls sense

const DEF_X_SENSE := 1.0
const DEF_Y_SENSE := 1.0

static func set_x_sense(value: float) -> void:
	M_PlayerConfig.set_config(INPUT_SECTION, X_MOUSE_SENSE, value)
	# __log_("set_x_sense", value)
	SigUtils.safe_emit_no_payload(GlobalSignal.SIG_update_mouse_settings_for_camera)


static func get_x_sense() -> float:
	return M_PlayerConfig.get_config(INPUT_SECTION, X_MOUSE_SENSE, DEF_X_SENSE)


static func _set_x_sense_from_config() -> void:
	var default_val: float = DEF_X_SENSE
	var saved_val: float = M_PlayerConfig.get_config(INPUT_SECTION, X_MOUSE_SENSE, default_val)
	set_x_sense(saved_val)


static func set_y_sense(value: float) -> void:
	M_PlayerConfig.set_config(INPUT_SECTION, Y_MOUSE_SENSE, value)
	# __log_("set_y_sense", value)
	SigUtils.safe_emit_no_payload(GlobalSignal.SIG_update_mouse_settings_for_camera)


static func get_y_sense() -> float:
	return M_PlayerConfig.get_config(INPUT_SECTION, Y_MOUSE_SENSE, DEF_Y_SENSE)


static func _set_y_sense_from_config() -> void:
	var default_val: float = DEF_Y_SENSE
	var saved_val: float = M_PlayerConfig.get_config(INPUT_SECTION, Y_MOUSE_SENSE, default_val)
	set_y_sense(saved_val)


static func set_controls_from_config() -> void:
	_set_x_sense_from_config()
	_set_y_sense_from_config()


# region: All

static func set_from_config() -> void:
	set_default_inputs()
	set_inputs_from_config()
	set_controls_from_config()
	set_audio_from_config()

static func set_from_config_and_window(window: Window) -> void:
	set_from_config()
	set_video_from_config(window)


## 


static func remove_developer_actions() -> void:
	if not eu.is_release():
		return

	__log_("M_AppSettings", "Release Build detected: Purging developer actions...")

	var actions = InputMap.get_actions()
	for action in actions:
		if action.begins_with("dev_") or action.begins_with("DEV_"):
			InputMap.erase_action(action)


static func pp_name() -> String:
	return "M_AppSettings"

static func __LOG_B() -> bool:
	return true

static func __LOG_INDENT() -> int:
	return 10

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.msg_raw(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())
