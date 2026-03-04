class_name BreakStaticParent
extends Node3DSystem


## currently hard coded column implementation


@export var shattered_column_scene: PackedScene


@onready var breakable_column_area: BreakableColumnArea = %BreakableColumnArea


var __is_broke: bool = false


func __hard_dependencies() -> Array:
	return [
		shattered_column_scene,
		breakable_column_area
	]

func __hard_validation() -> bool:
	if not breakable_column_area is BreakableColumnArea:
		return false
	if not _find_static_parent():
		return false
	return true


func _find_static_parent() -> StaticBody3D:
	var parent := get_parent()
	if not parent or not parent is StaticBody3D:
		return null
	return parent


var static_parent: StaticBody3D


func _ready() -> void:
	initialize()


func initialize() -> void:
	if __perform_validation():
		static_parent = _find_static_parent()
		if static_parent:
			breakable_column_area.get_SIG_breaking_area_entered().connect(break_myself)

	
func _is_breakable() -> bool:
	if not shattered_column_scene:
		return false
	if not static_parent:
		return false
	if static_parent.is_queued_for_deletion():
		return false
	if __is_broke:
		__log_("Already is broken")
		return false
	return true


func break_myself() -> void:
	__log_("break_myself called")
	if not _is_breakable():
		return

	## in case we were called twice in one frame
	__is_broke = true

	__log_(em.mark_alt, "Gonna break myself")
	
	var shattered_column := shattered_column_scene.instantiate()
	var scene_root := get_tree().current_scene
	scene_root.add_child(shattered_column)
	shattered_column.global_transform = static_parent.global_transform
	
	static_parent.queue_free()


## __LOGS
# region

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
