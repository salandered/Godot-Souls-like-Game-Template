@tool

@abstract
class_name BaseDVCollShapes
extends DTCSignalEnabledNode3D


@export var level: BaseLevel


@export_group("Material Settings")
@export var use_default_wireframe_mat: bool = true

@export_subgroup("Default wireframe mat settings")
@export var shader_color := Color.GREEN
@export var shader_transparency := 0.08
@export var shader_line_transparency := 0.5
@export var shader_use_perspective := false
@export_range(0.0, 5.0) var shader_wire_width := 1.0
@export var shader_grid_density := Vector2(5.0, 2.0)
@export var use_barycentric: bool = false


const MUTED_CATEGORY := &"muted"
const DEF_CATEGORY := &"default"
const DEF_COLOR := Color.GRAY


var _generated_nodes: Array[MeshInstance3D] = []
var _cached_mats: Dictionary[String, Material] = {}
var _base_material: Material


func __hard_dependencies() -> Array:
	return [
		level
	]


func _initialize_implementation_in_game() -> void:
	if not level:
		return
	_init_base_material()

	if _base_material:
		_initialize_visuals()


func _init_base_material() -> void:
	if use_default_wireframe_mat:
		_shared_material_as_default_mat()

	if not _base_material:
		_shared_material_as_standard()


func _initialize_visuals() -> void:
	_delete_all_visuals()
	_cached_mats.clear()

	_initialize_visuals_implementation()
	__log_("_initialize_visuals", "count", len(_generated_nodes))


@abstract func _initialize_visuals_implementation() -> void


func _delete_all_visuals() -> void:
	for node in _generated_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_generated_nodes.clear()


func set_enabled(value: bool) -> void:
	super.set_enabled(value)
	
	for node in _generated_nodes:
		if is_instance_valid(node):
			node.visible = value


func _shared_material_as_default_mat():
	_base_material = WireFrameMat.create_wireframe_shader(
		shader_color,
		shader_transparency,
		shader_line_transparency,
		shader_use_perspective,
		shader_wire_width,
		shader_grid_density,
		use_barycentric
	)
	__log_("initted shader with params", use_barycentric, shader_line_transparency)


func _shared_material_as_standard():
	_base_material = MaterialUtils.create_standard_mat_3d(
		shader_color,
		BaseMaterial3D.SHADING_MODE_UNSHADED,
		BaseMaterial3D.TRANSPARENCY_ALPHA,
		false,
		null,
		BaseMaterial3D.CULL_DISABLED
	)


func _exit_tree() -> void:
	_delete_all_visuals()


## currently should be manually called from implementations
func _get_or_create_mat_by_category(category: StringName, category_to_mat: Dictionary[StringName, Color]) -> Material:
	if category in _cached_mats:
		return _cached_mats[category]
		
	var color: Color = category_to_mat.get(category, DEF_COLOR)
	var new_mat := _base_material.duplicate()
	
	if new_mat is ShaderMaterial:
		WireFrameMat.set_albedo(new_mat, color)
	elif new_mat is StandardMaterial3D:
		new_mat.albedo_color = color
		
	_cached_mats[category] = new_mat
	return new_mat


##

func __LOG_B() -> bool:
	return true
