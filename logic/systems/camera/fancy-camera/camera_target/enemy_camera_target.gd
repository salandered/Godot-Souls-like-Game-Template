extends BaseCameraTarget
class_name EnemyCameraTarget


var _assigned_parent: Node3D

@onready var look_at_point: Node3D = $LookAt


func initialise(assigned_parent: Node3D) -> void:
	_assigned_parent = assigned_parent
	add_to_group(Groups.Environment_.TARGETABLE) # only for EnemyCameraTarget
	
	assert(_assigned_parent, "_assigned_parent should be set for EnemyCameraTarget")

	dev_initialise()
	

# func _process(delta: float) -> void:
# 	prints(pp.s(self.global_position))


func pp_name() -> String:
	return pp.s("EnemyCamTarget", _assigned_parent.name)


## non nullable
func get_assigned_parent() -> Node3D:
	return _assigned_parent


func make_inactive() -> void:
	_is_active = false

func make_active() -> void:
	_is_active = true


## DEV


# NOTE: experimental. probably not the best way to do this. Not used
func is_about_to_die() -> bool:
	if self.is_queued_for_deletion():
		prints("EnemyCameraTarget is_queued_for_deletion => true", self)
		return true
	
	var parent := get_parent()
	if not is_instance_valid(parent):
		prints("EnemyCameraTarget parent is not valid => true", self)
		return true
	if parent.is_queued_for_deletion():
		prints("EnemyCameraTarget parent is_queued_for_deletion => true", self)
		return true

	var assigned_parent := get_assigned_parent()
	if not is_instance_valid(assigned_parent):
		prints("EnemyCameraTarget assigned_parent is not valid => true", self)
		return true
	if assigned_parent.is_queued_for_deletion():
		prints("EnemyCameraTarget assigned_parent is_queued_for_deletion => true", self)
		return true
	
	return false


@export var __csg_visual: bool = true
@onready var csg_marker: CSGSphere3D = $LookAt/CSGMarker

func dev_initialise():
	csg_marker.visible = __csg_visual


# func _input(event: InputEvent):
# 	look_at_point.global_position.y = u._dev_change_t67_param(event, look_at_point.global_position.y, "look_at_point.global_position.y", 0.2)
