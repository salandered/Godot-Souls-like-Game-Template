class_name M_GlobalState
extends Node


const SAVE_STATE_PATH = "user://m_global_state.tres"
const NO_VERSION_NAME = "0.0.0"

static var current: M_GlobalStateData
static var current_version: String


static func _log_opened() -> void:
	if current is M_GlobalStateData:
		current.last_unix_time_opened = int(TimeUtils.get_sys_unix_time())


static func _log_version() -> void:
	if current is M_GlobalStateData:
		current_version = ProjectSettings.get_setting(PropC.APPLICATION_CONFIG_VERSION, NO_VERSION_NAME)
		if current_version.is_empty():
			current_version = NO_VERSION_NAME
		if not current.first_version_opened:
			current.first_version_opened = current_version
		current.last_version_opened = current_version


static func _load_current_state() -> void:
	if FileAccess.file_exists(SAVE_STATE_PATH):
		current = ResourceLoader.load(SAVE_STATE_PATH)
	if not current:
		current = M_GlobalStateData.new()


static func open() -> void:
	_load_current_state()
	_log_opened()
	_log_version()
	save()


static func save() -> void:
	if current is M_GlobalStateData:
		ResourceSaver.save(current, SAVE_STATE_PATH)


static func has_state(state_key: String) -> bool:
	if current is not M_GlobalStateData: return false
	return current.has_state(state_key)


static func get_or_create_state(state_key: String, state_type_path: String) -> Resource:
	if current is not M_GlobalStateData: return
	return current.get_or_create_state(state_key, state_type_path)


static func reset() -> void:
	if current is not M_GlobalStateData: return
	current.states.clear()
	save()
