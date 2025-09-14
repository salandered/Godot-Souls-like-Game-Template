extends Control


var entrypoint: Entrypoint


@onready var ui = $UI
@onready var one_lvl_menu = ui.get_node("OneLevelMenu")
@onready var settings_menu = ui.get_node("Settings")

# MAIN BUTTONS
@onready var play_button = one_lvl_menu.get_node("Play")
@onready var settings_button = one_lvl_menu.get_node("Settings")
@onready var quit_button = one_lvl_menu.get_node("Quit")

# SETTINGS MENU 
@onready var settings_actions = settings_menu.get_node("Actions")
@onready var display_mode_menu = settings_menu.get_node("DisplayMode")
@onready var vsync_menu = settings_menu.get_node("VSync")
@onready var max_fps_menu = settings_menu.get_node("MaxFPS")
@onready var resolution_scale_menu = settings_menu.get_node("ResolutionScale")
@onready var scale_filter_menu = settings_menu.get_node("ScaleFilter")
@onready var taa_menu = settings_menu.get_node("TAA")
@onready var msaa_menu = settings_menu.get_node("MSAA")
@onready var fxaa_menu = settings_menu.get_node("FXAA")
@onready var shadow_mapping_menu = settings_menu.get_node("ShadowMapping")
@onready var gi_type_menu = settings_menu.get_node("GIType")
@onready var gi_quality_menu = settings_menu.get_node("GIQuality")
@onready var ssao_menu = settings_menu.get_node("SSAO")
@onready var glow_menu = settings_menu.get_node("Glow")
@onready var volumetric_fog_menu = settings_menu.get_node("VolumetricFog")


# SETTINGS SUBMENU
@onready var settings_action_apply = settings_actions.get_node("Apply")
@onready var settings_action_cancel = settings_actions.get_node("Cancel")

@onready var display_mode_windowed = display_mode_menu.get_node("Windowed")
@onready var display_mode_fullscreen = display_mode_menu.get_node("Fullscreen")
@onready var display_mode_exclusive_fullscreen = display_mode_menu.get_node("ExclusiveFullscreen")

@onready var vsync_disabled = vsync_menu.get_node("Disabled")
@onready var vsync_enabled = vsync_menu.get_node("Enabled")
@onready var vsync_adaptive = vsync_menu.get_node("Adaptive")
@onready var vsync_mailbox = vsync_menu.get_node("Mailbox")

@onready var max_fps_30 = max_fps_menu.get_node("30")
@onready var max_fps_60 = max_fps_menu.get_node("60")
@onready var max_fps_90 = max_fps_menu.get_node("90")
@onready var max_fps_120 = max_fps_menu.get_node("120")
@onready var max_fps_unlimited = max_fps_menu.get_node("Unlimited")

@onready var resolution_scale_10_20 = resolution_scale_menu.get_node("Scale1020")
@onready var resolution_scale_10_15 = resolution_scale_menu.get_node("Scale1015")
@onready var resolution_scale_native = resolution_scale_menu.get_node("Native")


@onready var scale_filter_bilinear = scale_filter_menu.get_node("Bilinear")
@onready var scale_filter_fsr1 = scale_filter_menu.get_node("FSR1")
@onready var scale_filter_fsr2 = scale_filter_menu.get_node("FSR2")

@onready var taa_disabled = taa_menu.get_node("Disabled")
@onready var taa_enabled = taa_menu.get_node("Enabled")

@onready var msaa_disabled = msaa_menu.get_node("Disabled")
@onready var msaa_2x = msaa_menu.get_node("2X")
@onready var msaa_4x = msaa_menu.get_node("4X")
@onready var msaa_8x = msaa_menu.get_node("8X")

@onready var fxaa_disabled = fxaa_menu.get_node("Disabled")
@onready var fxaa_enabled = fxaa_menu.get_node("Enabled")

@onready var shadow_mapping_disabled = shadow_mapping_menu.get_node("Disabled")
@onready var shadow_mapping_enabled = shadow_mapping_menu.get_node("Enabled")

@onready var gi_lightmapgi = gi_type_menu.get_node("LightmapGI")
@onready var gi_voxelgi = gi_type_menu.get_node("VoxelGI")
@onready var gi_sdfgi = gi_type_menu.get_node("SDFGI")

@onready var gi_disabled = gi_quality_menu.get_node("Disabled")
@onready var gi_low = gi_quality_menu.get_node("Low")
@onready var gi_high = gi_quality_menu.get_node("High")

@onready var ssao_disabled = ssao_menu.get_node("Disabled")
@onready var ssao_medium = ssao_menu.get_node("Medium")
@onready var ssao_high = ssao_menu.get_node("High")

@onready var glow_disabled = glow_menu.get_node("Disabled")
@onready var glow_enabled = glow_menu.get_node("Enabled")

@onready var volumetric_fog_disabled = volumetric_fog_menu.get_node("Disabled")
@onready var volumetric_fog_enabled = volumetric_fog_menu.get_node("Enabled")

@onready var camera_3d: Camera3D = $Camera3D


func make_camera_current():
	if camera_3d:
		camera_3d.make_current()


func _ready():
	one_lvl_menu.show()
	settings_menu.hide()

	play_button.grab_focus()

	for menu in [
		display_mode_menu, vsync_menu, max_fps_menu, resolution_scale_menu, scale_filter_menu,
		taa_menu, msaa_menu, fxaa_menu, shadow_mapping_menu, gi_type_menu, gi_quality_menu,
		ssao_menu, glow_menu, volumetric_fog_menu,
	]:
		_make_button_group(menu)


func _make_button_group(common_parent: Node):
	var group = ButtonGroup.new()
	for btn in common_parent.get_children():
		if not btn is BaseButton:
			continue
		btn.button_group = group


func _on_play_pressed():
	print("Play button pressed")
	entrypoint.show_level()

func _on_settings_pressed():
	print("Settings button pressed")
	one_lvl_menu.hide()
	settings_menu.show()
	settings_action_cancel.grab_focus()

	_align_ui_settings_with_config()

func _on_apply_pressed():
	print("Apply button pressed")
	one_lvl_menu.show()
	play_button.grab_focus()
	settings_menu.hide()

	_align_config_with_ui_settings()

	var environment = null
	if entrypoint.is_level_loaded():
		environment = entrypoint._level.world_environment.environment


	_apply_graphics_settings(get_window(), environment)

	Settings.save_settings()


func _on_quit_pressed():
	print("Quit button pressed")
	get_tree().quit()


func _on_cancel_pressed():
	print("Cancel button pressed")
	one_lvl_menu.show()
	play_button.grab_focus()
	settings_menu.hide()


func _align_ui_settings_with_config():
	if Settings.config_file.get_value("video", "display_mode") == Window.MODE_WINDOWED \
			or Settings.config_file.get_value("video", "display_mode") == Window.MODE_MAXIMIZED:
		display_mode_windowed.button_pressed = true
	elif Settings.config_file.get_value("video", "display_mode") == Window.MODE_FULLSCREEN:
		display_mode_fullscreen.button_pressed = true
	else:
		display_mode_exclusive_fullscreen.button_pressed = true

	if Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_DISABLED:
		vsync_disabled.button_pressed = true
	elif Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_ENABLED:
		vsync_enabled.button_pressed = true
	elif Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_ADAPTIVE:
		vsync_adaptive.button_pressed = true
	else:
		vsync_mailbox.button_pressed = true

	if Settings.config_file.get_value("video", "max_fps") == 30:
		max_fps_30.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 60:
		max_fps_60.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 90:
		max_fps_90.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 120:
		max_fps_120.button_pressed = true
	else:
		max_fps_unlimited.button_pressed = true

	if is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 2.0):
		resolution_scale_10_20.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.5):
		resolution_scale_10_15.button_pressed = true
	else:
		resolution_scale_native.button_pressed = true

	if Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_BILINEAR:
		scale_filter_bilinear.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_FSR:
		scale_filter_fsr1.button_pressed = true
	else:
		scale_filter_fsr2.button_pressed = true

	if Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.LIGHTMAP_GI:
		gi_lightmapgi.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.VOXEL_GI:
		gi_voxelgi.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.SDFGI:
		gi_sdfgi.button_pressed = true

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.DISABLED:
		gi_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		gi_low.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.HIGH:
		gi_high.button_pressed = true

	if not Settings.config_file.get_value("rendering", "taa"):
		taa_disabled.button_pressed = true
	else:
		taa_enabled.button_pressed = true

	if Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_DISABLED:
		msaa_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_2X:
		msaa_2x.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_4X:
		msaa_4x.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_8X:
		msaa_8x.button_pressed = true

	if not Settings.config_file.get_value("rendering", "fxaa"):
		fxaa_disabled.button_pressed = true
	else:
		fxaa_enabled.button_pressed = true

	if not Settings.config_file.get_value("rendering", "shadow_mapping"):
		shadow_mapping_disabled.button_pressed = true
	else:
		shadow_mapping_enabled.button_pressed = true

	if Settings.config_file.get_value("rendering", "ssao_quality") == -1:
		ssao_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssao_quality") == RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
		ssao_medium.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssao_quality") == RenderingServer.ENV_SSAO_QUALITY_HIGH:
		ssao_high.button_pressed = true

	if not Settings.config_file.get_value("rendering", "glow"):
		glow_disabled.button_pressed = true
	else:
		glow_enabled.button_pressed = true

	if not Settings.config_file.get_value("rendering", "volumetric_fog"):
		volumetric_fog_disabled.button_pressed = true
	else:
		volumetric_fog_enabled.button_pressed = true


func _align_config_with_ui_settings() -> void:
	if display_mode_windowed.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_WINDOWED)
	elif display_mode_fullscreen.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_FULLSCREEN)
	elif display_mode_exclusive_fullscreen.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_EXCLUSIVE_FULLSCREEN)

	if vsync_disabled.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_DISABLED)
	elif vsync_enabled.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_ENABLED)
	elif vsync_adaptive.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_ADAPTIVE)
	elif vsync_mailbox.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_MAILBOX)

	var _max_fps: int = 0
	if max_fps_30.button_pressed:
		_max_fps = 30
	elif max_fps_60.button_pressed:
		_max_fps = 60
	elif max_fps_90.button_pressed:
		_max_fps = 90
	elif max_fps_120.button_pressed:
		_max_fps = 120
	elif max_fps_unlimited.button_pressed:
		_max_fps = 0
	Settings.config_file.set_value("video", "max_fps", _max_fps)

	var _resolution_scale: float = 1.0
	if resolution_scale_10_20.button_pressed:
		_resolution_scale = 1.0 / 2.0
	elif resolution_scale_10_15.button_pressed:
		_resolution_scale = 1.0 / 1.5
	elif resolution_scale_native.button_pressed:
		_resolution_scale = 1.0
	Settings.config_file.set_value("video", "resolution_scale", _resolution_scale)

	if scale_filter_bilinear.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_BILINEAR)
	elif scale_filter_fsr1.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_FSR)
	elif scale_filter_fsr2.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_FSR2)

	if gi_lightmapgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.LIGHTMAP_GI)
	elif gi_voxelgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.VOXEL_GI)
	elif gi_sdfgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.SDFGI)

	if gi_low.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.LOW)
	elif gi_high.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.HIGH)
	elif gi_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.DISABLED)

	Settings.config_file.set_value("rendering", "taa", taa_enabled.button_pressed)

	if msaa_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_DISABLED)
	elif msaa_2x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_2X)
	elif msaa_4x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_4X)
	elif msaa_8x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_8X)

	Settings.config_file.set_value("rendering", "shadow_mapping", shadow_mapping_enabled.button_pressed)
	Settings.config_file.set_value("rendering", "fxaa", fxaa_enabled.button_pressed)

	if ssao_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", -1)
	elif ssao_medium.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", RenderingServer.ENV_SSAO_QUALITY_MEDIUM)
	elif ssao_high.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", RenderingServer.ENV_SSAO_QUALITY_HIGH)


	Settings.config_file.set_value("rendering", "glow", glow_enabled.button_pressed)
	Settings.config_file.set_value("rendering", "volumetric_fog", volumetric_fog_enabled.button_pressed)


func _apply_graphics_settings(window: Window, environment: Variant):
	if not environment:
		push_warning("no environment passed to _apply_graphics_settings")

	print_.prefix("SETTINGS", "Applying settings\n" + Settings.config_file.to_string() + "\n")
	get_window().mode = Settings.config_file.get_value("video", "display_mode")
	DisplayServer.window_set_vsync_mode(Settings.config_file.get_value("video", "vsync"))
	Engine.max_fps = Settings.config_file.get_value("video", "max_fps")
	window.scaling_3d_scale = Settings.config_file.get_value("video", "resolution_scale")
	window.scaling_3d_mode = Settings.config_file.get_value("video", "scale_filter")

	window.use_taa = Settings.config_file.get_value("rendering", "taa")
	window.msaa_3d = Settings.config_file.get_value("rendering", "msaa")
	window.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if Settings.config_file.get_value("rendering", "fxaa") else Viewport.SCREEN_SPACE_AA_DISABLED

	# TODO: toggle only lights that were turned on by design
	#       and pass level somehow safe
	# var enable_shadows := bool(Settings.config_file.get_value("rendering", "shadow_mapping"))
	# _set_shadows_for_all_lights(entrypoint.level, enable_shadows)

	if environment:
		if Settings.config_file.get_value("rendering", "ssao_quality") == -1:
			environment.ssao_enabled = false
		if Settings.config_file.get_value("rendering", "ssao_quality") == RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
			environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, false, 0.5, 2, 50, 300)
		else:
			environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)

		environment.glow_enabled = Settings.config_file.get_value("rendering", "glow")
		environment.volumetric_fog_enabled = Settings.config_file.get_value("rendering", "volumetric_fog")


func _set_shadows_for_all_lights(root: Node, enabled: bool) -> void:
	for child in root.get_children():
		if child is DirectionalLight3D or child is OmniLight3D or child is SpotLight3D:
			child.shadow_enabled = enabled
		_set_shadows_for_all_lights(child, enabled)
