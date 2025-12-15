extends BreakableStatic
class_name BreakableColumn

## nullable
@export var shattered_column_scene: PackedScene

## nullable
var _breakable_area: BreakableArea

var __is_broke: bool = false


func initialise() -> void:
	if not shattered_column_scene:
		__log_error("no shattered_column_scene", "init", "wont be breakable")

	
	var _mesh_instances := get_descendants.mesh_instances_visible(self)
	var _areas := get_descendants.breakable_areas(self)

	if len(_mesh_instances) == 0:
		__log_error("zero _mesh_instances", "init", "it's just strange to have breakable invisible object")

	if len(_areas) != 1:
		__log_error("zero or more than one breakable areas found", "BreakableStatic init", "wont be breakable")
		_breakable_area = null
	else:
		_breakable_area = _areas[0]
		# __log_("Signal connected")

		_breakable_area.get_SIG_breaking_area_entered().connect(break_myself)

	
func _is_breakable() -> bool:
	return shattered_column_scene != null and _breakable_area != null


func break_myself() -> void:
	__log_("break_myself called")

	if not _is_breakable():
		__log_error("can't break myself. not enough data provided on init", "break_myself", "nothing")
		return

	## in case we were called twice in one frame
	if __is_broke:
		__log_("Already is broken")
		return

	__is_broke = true
	__log_(em.mark_alt, "Gonna break myself")
	var shattered_column := shattered_column_scene.instantiate()
	get_parent().add_child(shattered_column)
	shattered_column.global_transform = global_transform
	queue_free()
