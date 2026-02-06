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
		var mat := StandardMaterial3D.new()
		mat.shading_mode = shading_mode
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mi.material_override = mat
	
	return mi


## Positions a cylinder mesh between two points
## Assumes the mesh is Y-aligned (default Godot Cylinder)
static func place_cylinder_between(mi: MeshInstance3D, pos_a: Vector3, pos_b: Vector3, color: Color) -> void:
	if pos_a.is_equal_approx(pos_b):
		mi.visible = false
		return

	# resets scale to 1: ensures xz (thickness) return to the original mesh radius
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


# Add to MeshInstanceUtils.gd

## Creates a temporary sphere at 'pos' that deletes itself after 'duration'
static func debug_draw_sphere(
	parent: Node,
	pos: Vector3,
	radius: float,
	color: Color,
	duration: float = 1.0
) -> void:
	# 1. Create Mesh
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	
	# 2. Setup Node & Material
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = mat
	
	# 3. Add to scene
	parent.add_child(mi)
	
	# 4. Auto-delete logic
	var tween := mi.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(mi.queue_free)


## Creates a temporary line between points that deletes itself after 'duration'
static func debug_draw_line(
	parent: Node,
	pos_a: Vector3,
	pos_b: Vector3,
	thickness: float,
	color: Color,
	duration: float = 1.0
) -> void:
	# 1. Create Cylinder (reusing your existing helper if you like, or manually)
	# We use a small radius for the "line" thickness
	var mi := create_generic_cylinder(thickness, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	
	# 2. Add to scene FIRST (needed for global position calculations in place_cylinder)
	parent.add_child(mi)
	
	# 3. Position it
	place_cylinder_between(mi, pos_a, pos_b, color)
	
	# 4. Auto-delete logic
	var tween := mi.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(mi.queue_free)


# region: __LOGS

static func pp_name() -> String:
	return "MeshInstanceUtils"

static func __LOG_B() -> bool:
	return true

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion