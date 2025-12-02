class_name M_PlayerConfig
extends Object

## Interface for a single configuration file [ConfigFile].

## A low-level static class that directly manages reading from and writing to the settings file.
## Focused wrapper for Godot's built-in [ConfigFile], handles physical file operations.
## Saves / loads key-value data to / from the 'user://player_config.cfg'
## Used by higher-level managers like M_AppSettings and has no knowledge of what the data actually means.

const CONFIG_FILE_LOCATION := "user://player_config.cfg"

static var config_file: ConfigFile

static func _init() -> void:
	load_config_file()

static func _save_config_file() -> void:
	var save_error: int = config_file.save(CONFIG_FILE_LOCATION)
	if save_error:
		push_error("save config file failed with error %d" % save_error)

static func load_config_file() -> void:
	if config_file != null:
		return
	config_file = ConfigFile.new()
	var load_error: int = config_file.load(CONFIG_FILE_LOCATION)
	if load_error:
		var save_error: int = config_file.save(CONFIG_FILE_LOCATION)
		if save_error:
			push_error("save config file failed with error %d" % save_error)

static func set_config(section: String, key: String, value) -> void:
	load_config_file()
	config_file.set_value(section, key, value)
	_save_config_file()

static func get_config(section: String, key: String, default = null) -> Variant:
	load_config_file()
	if section == "" or key == "":
		print_.warn(true, "empty section or key was asked", "get_config", "return null", "section/key/default", [section, key, default])
		return null

	if not config_file.has_section_key(section, key):
		if default == null:
			__log_ui.warn_(true, "Config key missing and NO default provided", "get_config", "return null", "section/key/default", [section, key, default])
			return null
		return default # if no key but default => return immediately
	
	return config_file.get_value(section, key, default)

static func has_section(section: String) -> bool:
	load_config_file()
	return config_file.has_section(section)

static func has_section_key(section: String, key: String) -> bool:
	load_config_file()
	return config_file.has_section_key(section, key)

static func erase_section(section: String) -> void:
	if has_section(section):
		config_file.erase_section(section)
		_save_config_file()

static func erase_section_key(section: String, key: String) -> void:
	if has_section_key(section, key):
		config_file.erase_section_key(section, key)
		_save_config_file()

static func get_section_keys(section: String) -> PackedStringArray:
	load_config_file()
	if config_file.has_section(section):
		return config_file.get_section_keys(section)
	return PackedStringArray()
