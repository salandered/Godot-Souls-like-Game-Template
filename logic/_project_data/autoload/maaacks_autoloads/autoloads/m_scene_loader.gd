extends NodeLogger

## Autoload ##


signal SIG_scene_loaded

@export_file("*.tscn") var loading_screen_path: String: set = set_loading_screen

@export_group("Debug")
@export var __debug_enabled: bool = false
@export var debug_lock_status: ResourceLoader.ThreadLoadStatus
@export_range(0, 1) var debug_lock_progress: float = 0.0

var _loading_screen: PackedScene
var _scene_path: String = ""
var _loaded_resource: Resource
var _background_loading: bool


## Global manager (Autoload) for loading scenes asynchronously.
## - Uses a background thread to load scenes.
## - Can display an optional loading screen for the player or load the next scene 
##    silently in the background while the current scene continues to run.
## - Provides the loading progress, which can be used to create loading bars
## - Emits a signal when the scene is fully loaded.


func _ready() -> void:
	set_process(false)


func _process(_delta) -> void:
	var status = get_status()
	match (status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			SigUtils.safe_emit_no_payload(SIG_scene_loaded)
			set_process(false)
			if not _background_loading:
				change_scene_to_resource()


func reload_current_scene() -> void:
	if not get_tree():
		__log_error("no get_tree")

	get_tree().reload_current_scene()


## Main menu and pause menu use this
func load_scene(scene_path: String, in_background: bool = false) -> void:
	M_ProjectMusicController.fade_out(2.5)
	if scene_path.is_empty():
		__log_error("no path given to load")
		return

	_scene_path = scene_path
	_background_loading = in_background

	## "Once a resource has been loaded by the engine, it is cached in memory"
	if ResourceLoader.has_cached(_scene_path):
		SigUtils.safe_emit_no_payload(SIG_scene_loaded)
		if not _background_loading:
			change_scene_to_resource()
		return
	
	## NOTE: core function. Loads the resource using additional thread
	ResourceLoader.load_threaded_request(_scene_path)
	set_process(true)
	if _does_loading_screen_exist() and not _background_loading:
		change_scene_to_loading_screen()


func get_status() -> ResourceLoader.ThreadLoadStatus:
	if __debug_enabled:
		return debug_lock_status
	if not _does_scene_path_exist():
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get_status(_scene_path)


## M_LoadingScreen uses this
func get_progress() -> float:
	if __debug_enabled:
		return debug_lock_progress
	if not _does_scene_path_exist():
		return 0.0
	var progress_array: Array = []
	ResourceLoader.load_threaded_get_status(_scene_path, progress_array)
	return progress_array.pop_back()


func get_resource() -> Resource:
	if not _does_scene_path_exist():
		return
	if ResourceLoader.has_cached(_scene_path):
		_loaded_resource = ResourceLoader.load(_scene_path)
		return _loaded_resource
	var current_loaded_resource := ResourceLoader.load_threaded_get(_scene_path)
	if current_loaded_resource != null:
		_loaded_resource = current_loaded_resource
	return _loaded_resource


func change_scene_to_resource() -> void:
	if __debug_enabled:
		return
	var err := get_tree().change_scene_to_packed(get_resource())
	if err:
		__log_error("failed to change scenes: %d" % err)
		get_tree().quit()


func change_scene_to_loading_screen() -> void:
	M_ProjectMusicController.fade_out(2.5)

	_background_loading = false
	var err := get_tree().change_scene_to_packed(_loading_screen)
	if err:
		__log_error("failed to change scenes to loading screen: %d" % err)
		get_tree().quit()


func set_loading_screen(value: String) -> void:
	if value == "":
		__log_error("value is empty", "set_loading_screen", "return")
		return

	loading_screen_path = value
	_loading_screen = load(loading_screen_path)


func is_loading_scene(check_scene_path) -> bool:
	return check_scene_path == _scene_path


func has_loading_screen() -> bool:
	return _loading_screen != null


func _does_scene_path_exist() -> bool:
	if _scene_path == "":
		__log_error("scene path is empty")
		return false
	return true


func _does_loading_screen_exist() -> bool:
	if not has_loading_screen():
		__log_error("loading screen is not set")
		return false
	return true
