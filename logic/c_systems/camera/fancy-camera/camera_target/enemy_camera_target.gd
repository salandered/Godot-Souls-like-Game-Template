extends BaseCameraTarget
class_name EnemyCameraTarget


var _assigned_parent: Node3D

@onready var look_at_point: Node3D = $LookAt
@onready var ui_marker: Marker3D = %UIMarker
@onready var ui_marker_visual: CSGSphere3D = $UIMarker/ui_marker_visual


func __soft_dependencies() -> Array[Object]:
	return [
		_assigned_parent
	]


func initialise(assigned_parent: Node3D) -> void:
	self._assigned_parent = assigned_parent
	add_to_group(Groups.Environment_.TARGETABLE) # only for EnemyCameraTarget
	
	
	ui_marker.global_position.y += Y_ui_marker_shift
	#ui_marker_visual.visible = false
	
	dev_initialise()
	__perform_validation()
	

# func _process(delta: float) -> void:
# 	prints(pp.s(self.global_position))


func pp_name() -> String:
	return pp.s("EnemyCamTarget", str(_assigned_parent.name) if _assigned_parent else "")


func make_inactive() -> void:
	_is_active = false

func make_active() -> void:
	_is_active = true


## DEV


# NOTE: experimental. probably not the best way to do this. Not used
# func is_about_to_die() -> bool:
# 	if self.is_queued_for_deletion():
# 		prints("EnemyCameraTarget is_queued_for_deletion => true", self)
# 		return true
	
# 	var parent := get_parent()
# 	if not is_instance_valid(parent):
# 		prints("EnemyCameraTarget parent is not valid => true", self)
# 		return true
# 	if parent.is_queued_for_deletion():
# 		prints("EnemyCameraTarget parent is_queued_for_deletion => true", self)
# 		return true

# 	var assigned_parent := get_assigned_parent()
# 	if not is_instance_valid(assigned_parent):
# 		prints("EnemyCameraTarget assigned_parent is not valid => true", self)
# 		return true
# 	if assigned_parent.is_queued_for_deletion():
# 		prints("EnemyCameraTarget assigned_parent is_queued_for_deletion => true", self)
# 		return true
	
# 	return false


@export var __csg_visual: bool = true
@onready var csg_marker: CSGSphere3D = $LookAt/CSGMarker

func dev_initialise():
	if not OS.is_debug_build():
		if csg_marker:
			csg_marker.visible = false
		return
	csg_marker.visible = __csg_visual


# func _input(event: InputEvent):
	# if not OS.is_debug_build():
	# 	return
# 	look_at_point.global_position.y = u._dev_change_t67_param(event, look_at_point.global_position.y, "look_at_point.global_position.y", 0.2)


# ## __LOGS
# # region

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0

# # endregion
