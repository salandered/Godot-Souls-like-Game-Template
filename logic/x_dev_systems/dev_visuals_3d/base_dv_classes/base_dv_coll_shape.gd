@tool

@abstract
class_name VisualiseCollShapes
extends BaseDevVisualiseProcess


@export_group("Material Settings")
## true - used default shader mat
## false - creates a standard simple mat
@export var use_default_wireframe_mat: bool = true

@export_subgroup("Default wireframe mat settings")
@export var shader_color := Color.GREEN
@export_range(0.0, 1.0) var shader_transparency := 0.0
@export_range(0.0, 1.0) var shader_line_transparency := 1.0
@export var shader_use_perspective := false
@export_range(0.0, 5.0) var shader_wire_width := 1.0
@export var shader_grid_density := Vector2(5.0, 2.0)
@export var use_barycentric: bool = false


var _generated_nodes: Array[MeshInstance3D] = []
var _shared_material: Material

const WIRE_FRAME_MAT = preload("uid://c0ppm6u2ki7fp")


func _initialise_implementation_in_game() -> void:
	super._initialise_implementation_in_game()
	
	_initialise_shapes()

	# __log_("initialise_implementation_in_game", "START")
	if use_default_wireframe_mat and WIRE_FRAME_MAT is ShaderMaterial:
		_shared_material_as_default_mat()
	else:
		_shared_material_as_standard()

		
	_initialise_visuals_for_shapes()
	# If no visuals were created, should not process
	if _generated_nodes.is_empty():
		__log_warn_soft("initialised, but no shapes to manage. Shutting down")
		set_enabled(false)
	# else:
		# __log_("initialise_implementation_in_game", "END")


## called before _get_shapes()
@abstract func _initialise_shapes() -> void


@abstract func _get_shapes() -> Array[CollisionShape3D]


func _initialise_visuals_for_shapes() -> void:
	_delete_all_visuals()
	
	for col_shape in _get_shapes():
		if not is_instance_valid(col_shape) or not col_shape.shape:
			continue

		var mesh_instance := MeshInstanceUtils.create_based_on_shape_3d(col_shape.shape)
		if mesh_instance:
			mesh_instance.material_override = _shared_material
			col_shape.add_child(mesh_instance)
			_generated_nodes.append(mesh_instance)
	_set_visuals_color(_get_initial_color())


## can be overriden
func _get_initial_color() -> Color:
	return shader_color


func _set_visuals_color(color: Color) -> void:
	if not _shared_material:
		return
		
	if _shared_material is StandardMaterial3D:
		_shared_material.albedo_color = color
	elif _shared_material is ShaderMaterial:
		_shared_material.set_shader_parameter("albedo", color)


func _delete_all_visuals() -> void:
	for node in _generated_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_generated_nodes.clear()


func reset_visuals() -> void:
	_set_nodes_visibility(false)


func set_enabled(value: bool) -> void:
	__log_("set_enabled", value)
	super.set_enabled(value)
	_set_nodes_visibility(value)


func _set_nodes_visibility(value: bool) -> void:
	__log_("_set_nodes_visibility", value)
	for node in _generated_nodes:
		if is_instance_valid(node):
			node.visible = value


func _shared_material_as_default_mat():
	_shared_material = WIRE_FRAME_MAT.duplicate()
	_shared_material.set_shader_parameter("albedo", shader_color)
	_shared_material.set_shader_parameter("transparency", shader_transparency)
	_shared_material.set_shader_parameter("line_transparency", shader_line_transparency)
	_shared_material.set_shader_parameter("use_perspective", shader_use_perspective)
	_shared_material.set_shader_parameter("wire_width", shader_wire_width)
	_shared_material.set_shader_parameter("grid_density", shader_grid_density)
	_shared_material.set_shader_parameter("use_barycentric", use_barycentric)
	__log_("initted shader with params", use_barycentric, shader_line_transparency)

	
func _shared_material_as_standard():
	_shared_material = MatUtils.create_standard_3d(
		shader_color,
		BaseMaterial3D.SHADING_MODE_UNSHADED,
		BaseMaterial3D.TRANSPARENCY_ALPHA,
		false,
		null,
		BaseMaterial3D.CULL_DISABLED
	)
