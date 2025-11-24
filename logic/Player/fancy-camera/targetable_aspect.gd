extends Node3D
class_name CameraTarget


@export var _assigned_parent: Node3D
@export var __csg_visual: bool = true
@onready var csg_marker: CSGSphere3D = $LookAt/CSGMarker
@onready var look_at_point: Node3D = $LookAt


var label: String = "not assigned"


func _ready() -> void:
	add_to_group(Groups.Environment_.TARGETABLE)
	csg_marker.visible = __csg_visual
	assert(_assigned_parent, "_assigned_parent should be set")
	
func _input(event):
	look_at_point.global_position.y = u._dev_change_t67_param(event, look_at_point.global_position.y, "look_at_point.global_position.y", 0.2)


## non nullable
func get_assigned_parent() -> Node3D:
	return _assigned_parent


func is_about_to_die() -> bool:
	if self.is_queued_for_deletion():
		prints("CameraTarget is_queued_for_deletion => true", self)
		return true
	
	var parent = get_parent()
	if not is_instance_valid(parent):
		prints("CameraTarget parent is not valid => true", self)
		return true
	if parent.is_queued_for_deletion():
		prints("CameraTarget parent is_queued_for_deletion => true", self)
		return true

	var assigned_parent = get_assigned_parent()
	if not is_instance_valid(assigned_parent):
		prints("CameraTarget assigned_parent is not valid => true", self)
		return true
	if assigned_parent.is_queued_for_deletion():
		prints("CameraTarget assigned_parent is_queued_for_deletion => true", self)
		return true
	
	return false
