class_name MeshInstanceUtils
extends RefCountedStaticLogger


static func create_generic_cylinder(
	radius: float,
	cast_shadow := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,
	shading_mode := BaseMaterial3D.SHADING_MODE_UNSHADED,
	create_material := true
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 1.0
	mi.mesh = mesh
	
	mi.cast_shadow = cast_shadow
	
	if create_material:
		mi.material_override = MatUtils.create_standard_3d(
			Color.WHITE,
			shading_mode,
			BaseMaterial3D.TRANSPARENCY_ALPHA
		)
	return mi


## cylinder mesh between two points
static func place_cylinder_between(mi: MeshInstance3D, pos_a: Vector3, pos_b: Vector3, color: Color) -> void:
	if pos_a.is_equal_approx(pos_b):
		mi.visible = false
		return

	# resets scale: ensures xz (thickness) return to the original mesh radius
	mi.scale = Vector3.ONE

	# position at midpoint
	mi.global_position = (pos_a + pos_b) / 2.0
	
	# rotation
	var up_vec := Vector3.UP
	if abs(pos_a.direction_to(pos_b).dot(Vector3.UP)) > 0.99:
		up_vec = Vector3.RIGHT
	
	u.safe_look_at(mi, pos_b, up_vec)
	
	# correction for Y-up cylinder geometry to point along Z-forward vector
	mi.rotate_object_local(Vector3.RIGHT, -PI / 2.0)

	# scale: modify y (length). xz remain 1.0 (constant thickness)
	mi.scale.y = pos_a.distance_to(pos_b)
	
	# color
	var mat := mi.material_override as StandardMaterial3D
	if mat:
		color.a = 1.0
		mat.albedo_color = color

	mi.visible = true


static func create_based_on_shape_3d(shape: Shape3D) -> MeshInstance3D:
	var mesh: PrimitiveMesh = null
	
	if shape is BoxShape3D:
		mesh = BoxMesh.new()
		mesh.size = shape.size
	elif shape is SphereShape3D:
		mesh = SphereMesh.new()
		mesh.radius = shape.radius
		mesh.height = shape.radius * 2
	elif shape is CapsuleShape3D:
		mesh = CapsuleMesh.new()
		mesh.radius = shape.radius
		mesh.height = shape.height
	elif shape is CylinderShape3D:
		mesh = CylinderMesh.new()
		mesh.top_radius = shape.radius
		mesh.bottom_radius = shape.radius
		mesh.height = shape.height
	else:
		__log_warn("shape3d is not supported", "", "", shape)
	
	if mesh:
		var node = MeshInstance3D.new()
		node.mesh = mesh
		return node
		
	return null


static func create_simple_sphere(
	radius: float = 0.5,
	color: Color = Color.ORANGE_RED,
	shading_mode: BaseMaterial3D.ShadingMode = BaseMaterial3D.SHADING_MODE_UNSHADED,
	no_depth_test: bool = false
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	mi.material_override = MatUtils.create_standard_3d(
		color,
		shading_mode,
		BaseMaterial3D.TRANSPARENCY_DISABLED,
		no_depth_test,
	)
	
	return mi


static func create_simple_box(
	size: Vector3,
	color: Color = Color.ORANGE_RED,
	shading_mode: BaseMaterial3D.ShadingMode = BaseMaterial3D.SHADING_MODE_UNSHADED,
	no_depth_test: bool = false
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	mi.material_override = MatUtils.create_standard_3d(
		color,
		shading_mode,
		BaseMaterial3D.TRANSPARENCY_DISABLED,
		no_depth_test
	)
	
	return mi


static func draw_temporary_sphere(
	parent: Node,
	pos: Vector3,
	radius: float = 0.1,
	color: Color = Color.GOLD,
	duration: float = 1.0,
	top_level: bool = true,
	shading_mode: BaseMaterial3D.ShadingMode = BaseMaterial3D.SHADING_MODE_UNSHADED,
	no_depth_test: bool = true,
) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	mi.material_override = MatUtils.create_standard_3d(
		color,
		shading_mode,
		BaseMaterial3D.TRANSPARENCY_ALPHA,
		no_depth_test,
		MatUtils.EmissionConfig.new() \
			if shading_mode == BaseMaterial3D.SHADING_MODE_PER_PIXEL \
			else null,
	)

	mi.top_level = top_level
	
	if parent:
		parent.add_child(mi)
		mi.global_position = pos
		
		var tween := mi.create_tween()
		tween.tween_interval(duration)
		tween.tween_callback(mi.queue_free)


## cylinder connecting 'from' to 'to' (Local Space).
static func create_bone_like_connector(
	from: Vector3,
	to: Vector3,
	color: Color,
	width: float = 0.05
) -> MeshInstance3D:
	var v := to - from
	if v.length_squared() < 0.001: return null

	var mesh := CylinderMesh.new()
	mesh.top_radius = width * 0.7
	mesh.bottom_radius = width
	mesh.height = v.length()
	
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	mi.material_override = MatUtils.create_standard_3d(
		color,
		BaseMaterial3D.SHADING_MODE_PER_PIXEL,
	)

	mi.position = (from + to) / 2.0
	
	var up := Vector3.UP
	# handle vertical bones (prevent gimbal lock)
	if abs(v.normalized().dot(up)) > 0.99:
		up = Vector3.RIGHT
	
	# transform that looks at 'to' from 'mi.position'
	# looking_at aligns -z to the target
	mi.transform = mi.transform.looking_at(to, up)
	
	# cylinder is y-aligned
	# rotate -90 on x to bring y (cylinder) to -z (bone dir).
	mi.rotate_object_local(Vector3.RIGHT, -PI / 2.0)
		
	return mi
		

# region: __LOGS

static func pp_name() -> String:
	return "MeshInstanceUtils"

static func __LOG_B() -> bool:
	return true

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion