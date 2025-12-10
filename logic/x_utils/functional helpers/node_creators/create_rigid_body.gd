extends RefCountedStaticLogger
class_name RigidBodyCreator

class PhysicsConfig:
	var mass: float
	# 0.0   # Ice - slides forever
	# 0.3   # Plastic - slippery
	# 1.0   # Wood/default - moderate grip
	# 1.5   # Rubber - high grip, stops quickly
	var friction: float
	# 0.0   # Clay/sand - no bounce, dead stop
	# 0.2   # Wood - small bounce
	# 0.5   # Plastic ball - medium bounce
	# 0.9   # Rubber ball - high bounce
	# 1.0   # Superball - perfect bounce (no energy loss)
	var bounce: float
	# 1.0 - normal gravity (default)
	# < 1.0 - floaty, slow fall
	# > 1.0 - heavy, fast fall
	# 0.0 - no gravity, floats in place
	var gravity_scale: float
	
	func _init(
		mass_: float = 1.0,
		friction_: float = 1.0,
		bounce_: float = 0.0,
		gravity_scale_: float = 1.0
	) -> void:
		self.mass = mass_
		self.friction = friction_
		self.bounce = bounce_
		self.gravity_scale = gravity_scale_
	
	func _to_string() -> String:
		return "mass: %.2f, fric: %.2f, bnc: %.2f, grav: %.2f" % [mass, friction, bounce, gravity_scale]


static func create_rigid_body_from_mesh_instance(
	mesh_instance: MeshInstance3D,
	physics_config: PhysicsConfig = null,
	use_geometry_center: bool = true
) -> RigidBody3D:
	if not mesh_instance or not mesh_instance.mesh:
		__log_error("Invalid MeshInstance3D or missing mesh", "", "return null", mesh_instance)
		return null

	if not physics_config:
		physics_config = PhysicsConfig.new()
	
	__log_("Creating rigid body from:", mesh_instance.name, "| use_geometry_center:", use_geometry_center, "| config:", physics_config)
	__log_("Original mesh global_position:", mesh_instance.global_position)
	
	var rigid_body := RigidBody3D.new()
	rigid_body.global_transform = mesh_instance.global_transform
	
	_setup_mesh(rigid_body, mesh_instance, use_geometry_center)
	
	if not _create_collision_shape(rigid_body, mesh_instance):
		rigid_body.queue_free()
		return null
	
	_apply_physics_config(rigid_body, physics_config)
	_setup_collision_layers(rigid_body)

	# __log_("✓ Rigid body created successfully for:", mesh_instance.name)
	return rigid_body


static func _setup_mesh(
	rigid_body: RigidBody3D,
	mesh_instance: MeshInstance3D,
	use_geometry_center: bool
) -> void:
	# (flags=0: just mesh and materials, no signals/groups/scripts)
	var new_mesh = mesh_instance.duplicate(0)
	rigid_body.add_child(new_mesh)
	new_mesh.transform = Transform3D.IDENTITY
	new_mesh.skeleton = NodePath("")
	new_mesh.extra_cull_margin = max(mesh_instance.extra_cull_margin, 16.0)
	new_mesh.cast_shadow = mesh_instance.cast_shadow
	var geometry_center := Vector3.ZERO
	if use_geometry_center:
		var mesh_aabb = mesh_instance.mesh.get_aabb()
		geometry_center = mesh_aabb.get_center()
		
		# Just set center of mass - don't offset mesh!
		rigid_body.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		rigid_body.center_of_mass = geometry_center
		
		__log_("  Mesh AABB center:", geometry_center, "| CoM set to geometry center")
	else:
		__log_("  Using default center of mass")
	

static func _create_collision_shape(
	rigid_body: RigidBody3D,
	mesh_instance: MeshInstance3D,
) -> bool:
	var convex_shape := mesh_instance.mesh.create_convex_shape(false)
	if not convex_shape:
		__log_error("Failed to create convex shape from mesh", "", "return null", mesh_instance)
		return false
	
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = convex_shape
	# No offset - collision at origin where mesh is
	rigid_body.add_child(collision_shape)
	
	__log_("  Collision shape created at origin")
	return true


static func _apply_physics_config(rigid_body: RigidBody3D, physics_config: PhysicsConfig) -> void:
	# Apply physics configuration
	rigid_body.mass = physics_config.mass
	rigid_body.gravity_scale = physics_config.gravity_scale
	rigid_body.physics_material_override = PhysicsMaterial.new()
	rigid_body.physics_material_override.friction = physics_config.friction
	rigid_body.physics_material_override.bounce = physics_config.bounce
	
	__log_("Physics config applied:", physics_config)


static func _setup_collision_layers(rigid_body: RigidBody3D) -> void:
	# coll layers
	rigid_body.collision_layer = Collision.Layers.ITEM_COL
	rigid_body.collision_mask = Collision.Masks.ITEM_COL_MASK
	
	__log_("Collision layers set | layer:", Collision.Layers.ITEM_COL, "| mask:", Collision.Masks.ITEM_COL_MASK)


# region: __LOGS


static func pp_name() -> String:
	return "RigidBodyCreator"

static func __LOG_B() -> bool:
	return false

static func __LOG_INDENT() -> int:
	return 10

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion