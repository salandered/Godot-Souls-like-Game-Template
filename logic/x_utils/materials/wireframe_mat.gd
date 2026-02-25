class_name WireFrameMat
extends RefCountedStaticLogger


const UID = "uid://c0ppm6u2ki7fp"
const WIRE_FRAME_MAT = preload(UID)


const ALBEDO = &"albedo"
const TRANSPARENCY = &"transparency"
const LINE_TRANSPARENCY = &"line_transparency"
const USE_PERSPECTIVE = &"use_perspective"
const WIRE_WIDTH = &"wire_width"
const GRID_DENSITY = &"grid_density"
const USE_BARYCENTRIC = &"use_barycentric"

## shader params
const REQUIRED_WIREFRAME_PARAMS: Array[StringName] = [
	ALBEDO,
	TRANSPARENCY,
	LINE_TRANSPARENCY,
	USE_PERSPECTIVE,
	WIRE_WIDTH,
	GRID_DENSITY,
	USE_BARYCENTRIC
]


## Cache state
static var _validation_checked: bool = false
static var _is_valid: bool = false


static func _validate_preloaded_mat() -> bool:
	if _validation_checked:
		return _is_valid

	_validation_checked = true

	if WIRE_FRAME_MAT is not ShaderMaterial or not WIRE_FRAME_MAT.shader:
		__log_warn("preloaded WIRE_FRAME_MAT is not valid", "", "", UID)
		_is_valid = false
		return false

	var casted_mat: ShaderMaterial = WIRE_FRAME_MAT
	var existing_uniforms: Array[StringName] = []

	## get_shader_uniform_list returns an Array of Dicts, which contains 'name' (value is as a String)
	## See similar dict: https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-get-property-list
	for uniform_list_item in casted_mat.shader.get_shader_uniform_list():
		if uniform_list_item.has(PropC.PROPERTY_LIST.NAME):
			existing_uniforms.append(uniform_list_item[PropC.PROPERTY_LIST.NAME])
	
	for req in REQUIRED_WIREFRAME_PARAMS:
		if not req in existing_uniforms:
			__log_warn("shader missing required param", "", "_is_valid set to false", req, casted_mat.shader.resource_path)
			_is_valid = false
			return false

	_is_valid = true
	return true


static func create_wireframe_shader(
	albedo: Color,
	transparency: float,
	line_transparency: float,
	use_perspective: bool,
	wire_width: float,
	grid_density: Vector2,
	use_barycentric: bool
) -> ShaderMaterial:
	if not _validate_preloaded_mat():
		__log_warn("create_wireframe_shader can't return a shader", "", "")
		return

	var new_mat := WIRE_FRAME_MAT.duplicate() as ShaderMaterial
	
	new_mat.set_shader_parameter(ALBEDO, albedo)
	new_mat.set_shader_parameter(TRANSPARENCY, transparency)
	new_mat.set_shader_parameter(LINE_TRANSPARENCY, line_transparency)
	new_mat.set_shader_parameter(USE_PERSPECTIVE, use_perspective)
	new_mat.set_shader_parameter(WIRE_WIDTH, wire_width)
	new_mat.set_shader_parameter(GRID_DENSITY, grid_density)
	new_mat.set_shader_parameter(USE_BARYCENTRIC, use_barycentric)
	
	return new_mat


static func set_albedo(mat: ShaderMaterial, albedo: Color) -> void:
	if not is_instance_valid(mat) or not mat.shader:
		__log_warn("invalid material or shader", "", "", mat)
		return

	# check param existence using map
	var has_param := false
	for uniform_list_item in mat.shader.get_shader_uniform_list():
		if uniform_list_item.has(PropC.PROPERTY_LIST.NAME) \
				and uniform_list_item[PropC.PROPERTY_LIST.NAME] == "albedo":
			has_param = true
			break
	
	if not has_param:
		__log_warn("shader missing albedo param", "", "")
		return

	mat.set_shader_parameter(ALBEDO, albedo)


# region: __LOGS

static func pp_name() -> String:
	return "WireFrameMat"

static func __LOG_B() -> bool:
	return true

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.msg_raw(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion