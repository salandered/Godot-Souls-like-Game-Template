@tool

@abstract
class_name BaseDevVisualizeVector3
extends BaseDevVisualizeProcess3D


@export var color := Color.TOMATO
@export var width := 0.04
@export var show_arrow := true

@export_group("Smoothing")
@export var enable_smoothing := false
@export var smoothing_speed := 15.0

var _mesh_instance: MeshInstance3D
var _arrow_instance: MeshInstance3D
var _smoothed_vector := Vector3.ZERO
var _has_valid_previous_vector := false

## INITIALIZATION
# region


# endregion

func _initialize_implementation_in_game() -> void:
	super._initialize_implementation_in_game()
	_initialize_mesh()


func _initialize_mesh() -> void:
	if _mesh_instance: return
	
	var mesh := CylinderMesh.new()
	mesh.height = 1.0
	
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = mesh
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	_mesh_instance.material_override = MaterialUtils.create_standard_mat_3d(
		color,
		BaseMaterial3D.SHADING_MODE_UNSHADED,
		BaseMaterial3D.TRANSPARENCY_ALPHA,
		true
	)
	
	add_child(_mesh_instance)

	if show_arrow:
		_arrow_instance = MeshInstanceUtils.create_arrow_tip(width, color)
		add_child(_arrow_instance)

	_update_width()


func _update_width() -> void:
	if not _mesh_instance: return
	var mesh := _mesh_instance.mesh as CylinderMesh
	if mesh:
		mesh.top_radius = width
		mesh.bottom_radius = width


# endregion

func set_enabled(value: bool):
	super.set_enabled(value)
	if _mesh_instance:
		_mesh_instance.visible = value
	if _arrow_instance:
		_arrow_instance.visible = value


func reset_visuals() -> void:
	if _mesh_instance:
		_mesh_instance.visible = false
	if _arrow_instance:
		_arrow_instance.visible = false
	_has_valid_previous_vector = false


@abstract func get_target_vector() -> Vector3


## PROCESS

func _conditions_to_visualize() -> bool:
	return true


func _process_visualization(delta: float) -> void:
	if not is_inside_tree() or not _mesh_instance: return
	
	var target := get_target_vector()
	
	if enable_smoothing:
		if _has_valid_previous_vector:
			_smoothed_vector = _smoothed_vector.lerp(target, delta * smoothing_speed)
		else:
			_smoothed_vector = target
			_has_valid_previous_vector = true
		target = _smoothed_vector
	else:
		_has_valid_previous_vector = false
	
	var length := target.length()
	if length < 0.001:
		_mesh_instance.visible = false
		if _arrow_instance: _arrow_instance.visible = false
		return
		
	_mesh_instance.visible = true
	_mesh_instance.scale = Vector3.ONE
	_mesh_instance.position = target / 2.0
	
	var up := Vector3.UP
	if abs(target.normalized().dot(up)) > 0.99:
		up = Vector3.RIGHT
		
	_mesh_instance.transform = _mesh_instance.transform.looking_at(target, up)
	_mesh_instance.rotate_object_local(Vector3.RIGHT, -PI / 2.0)
	
	_mesh_instance.scale.y = length
	
	if _arrow_instance:
		_arrow_instance.transform = _mesh_instance.transform
		_arrow_instance.scale = Vector3.ONE
		_arrow_instance.position = target


## LOGS


func __LOG_B() -> bool:
	return false