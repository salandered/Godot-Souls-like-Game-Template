extends Node
class_name Entrypoint


var level_path := "res://logic/Locations/level.tscn"
var menu_path := "res://ui/menu.tscn"

var level_scene: PackedScene
var menu_scene: PackedScene

var _level: Node3D = null
var _menu: Control = null

var __skip_menu: bool = false
var __dev_pre_load_level: bool = false
var __dev_load_menu: bool = true


# func get_level() -> Node3D:
# 	if not is_level_loaded: load_level()
# 	assert(_level != null)
# 	return _level

func is_level_loaded() -> bool:
	return _level != null

func _ready() -> void:
	if __skip_menu:
		__dev_pre_load_level = true
		__dev_load_menu = false

	randomize()
	# get_window().mode = Settings.config_file.get_value("video", "display_mode")

	# MENU
	if __dev_load_menu:
		menu_scene = load(menu_path) as PackedScene
		assert(menu_scene != null)
		_menu = menu_scene.instantiate()
		add_child(_menu)
		_menu.entrypoint = self

	# LEVEL
	if __dev_pre_load_level:
		load_level()

	if __dev_load_menu:
		show_menu() # start in menu
	elif is_level_loaded():
		show_level()
	else:
		print("In the beginning there was only darkness")


func load_level() -> void:
	level_scene = load(level_path) as PackedScene
	assert(level_scene != null)
	_level = level_scene.instantiate()
	add_child(_level)
	_level.entrypoint = self
	__dev_pre_load_level = true


# TODO: should i use Node.PROCESS_MODE_ALWAYS
func show_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_menu.show()
	_menu.process_mode = Node.PROCESS_MODE_INHERIT
	_menu.make_camera_current()
	if is_level_loaded():
		_level.hide()
		_level.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false

func show_level() -> void:
	if not is_level_loaded():
		load_level()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_level.show()
	_level.make_camera_current()
	_level.process_mode = Node.PROCESS_MODE_INHERIT
	if __dev_load_menu:
		_menu.hide()
		_menu.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
