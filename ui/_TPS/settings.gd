extends Node

enum GIType {
	SDFGI = 0,
	VOXEL_GI = 1,
	LIGHTMAP_GI = 2,
}

enum GIQuality {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

const CONFIG_FILE_PATH = "user://settings.ini"

const DEMO_DEFAULTS = {
	video = {
		display_mode = Window.MODE_EXCLUSIVE_FULLSCREEN,
		vsync = DisplayServer.VSYNC_ENABLED,
		max_fps = 0,
		resolution_scale = 1.0,
		scale_filter = Viewport.SCALING_3D_MODE_FSR2,
	},
	rendering = {
		taa = false,
		msaa = Viewport.MSAA_DISABLED,
		fxaa = false,
		shadow_mapping = true,
		gi_type = GIType.VOXEL_GI,
		gi_quality = GIQuality.LOW,
		ssao_quality = RenderingServer.ENV_SSAO_QUALITY_MEDIUM,
		glow = true,
		volumetric_fog = true,
	},
}

const MY_DEFAULTS = {
	video = {
		display_mode = Window.MODE_WINDOWED, # default new project opens in windowed mode
		vsync = DisplayServer.VSYNC_ENABLED, # vsync on by default
		max_fps = 0, # unlimited
		resolution_scale = 1.0, # no scaling
		scale_filter = Viewport.SCALING_3D_MODE_BILINEAR, # default scaling filter
	},
	rendering = {
		taa = false, # no temporal AA by default
		msaa = Viewport.MSAA_DISABLED, # disabled by default
		fxaa = false, # disabled by default
		shadow_mapping = true, # shadows on by default
		gi_type = GIType.VOXEL_GI, # no GI until user adds it
		gi_quality = GIQuality.LOW, # lowest sensible baseline
		ssao_quality = -1, # disabled by default
		glow = false, # not applied until user adds a Glow effect
		volumetric_fog = false, # off until user adds VolumetricFog node
	},
}

# var config_file := ConfigFile.new()


# func _ready():
# 	_load_settings()


# func _load_settings():
# 	var err = config_file.load(CONFIG_FILE_PATH)
# 	pp.pp_file_load_err(err, CONFIG_FILE_PATH)
# 	print_.prefix("SETTINGS", "Loaded config file\n" + config_file.to_string() + "\n")

# 	var DEFAULTS = MY_DEFAULTS # NOTE
# 	# defaults for values not found in config. ConfigFile.get_value() will always be valid
# 	for section in DEFAULTS:
# 		for key in DEFAULTS[section]:
# 			if not config_file.has_section_key(section, key):
# 				config_file.set_value(section, key, DEFAULTS[section][key])

# 	print_.prefix("SETTINGS", "Config file after setting defaults\n" + config_file.to_string() + "\n")

# func save_settings():
# 	print_.prefix("SETTINGS", "Saving new config file\n" + config_file.to_string() + "\n")
# 	config_file.save(CONFIG_FILE_PATH)
