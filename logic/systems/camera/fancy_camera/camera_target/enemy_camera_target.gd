extends BaseCameraTarget
class_name EnemyCameraTarget


var _assigned_parent: Node3D

@onready var look_at_point: Node3D = $LookAt
@onready var ui_marker: Marker3D = %UIMarker
@onready var ui_marker_visual: CSGSphere3D = $UIMarker/ui_marker_visual


func __soft_dependencies() -> Array:
	return [
		_assigned_parent
	]


func initialize(assigned_parent: Node3D) -> void:
	self._assigned_parent = assigned_parent
	add_to_group(Groups.Environment_.TARGETABLE) # only for EnemyCameraTarget
	
	
	ui_marker.global_position.y += Y_ui_marker_shift
	#ui_marker_visual.visible = false
	
	dev_initialize()
	__perform_validation()
	

func pp_name() -> String:
	return pp.s("EnemyCamTarget", str(_assigned_parent.name) if _assigned_parent else "")


func make_inactive() -> void:
	_is_active = false

func make_active() -> void:
	_is_active = true


## DEV


@export var __csg_visual: bool = true
@onready var look_at_visual: MeshInstance3D = %LookAtVisual

func dev_initialize():
	if eu.is_release():
		if look_at_visual:
			look_at_visual.visible = false
		return
	look_at_visual.visible = __csg_visual


# func _input(event: InputEvent):
	# if eu.is_release():
	# 	return
# 	look_at_point.global_position.y = InputUtils._dev_change_t67_param(event, look_at_point.global_position.y, "look_at_point.global_position.y", 0.2)
