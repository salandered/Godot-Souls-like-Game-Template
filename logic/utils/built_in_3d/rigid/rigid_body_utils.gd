class_name RigidBodyUtils
extends RefCountedStaticLogger


const RIGID_SHATTER_SCRIPT = preload("uid://cvdt0we2m7pch")


static func fully_create_rigid_body_from_mesh_instance(
	for_whom: Node3D,
	visual_mesh: MeshInstance3D,
	use_geometry_center_for_mass: bool = false,
	):
	var scene_root := for_whom.get_tree().current_scene
	
	if not visual_mesh.mesh:
		return

	var physics_config := RigidPhysicsConfig.new(3.0, 1.5, 0.0, 2.5)
	
	var rigid_body := RigidBodyUtils.create_rigid_body_from_mesh_instance(
		visual_mesh,
		physics_config,
		use_geometry_center_for_mass,
		true,
		false
	)
	
	if rigid_body:
		rigid_body.set_script(RIGID_SHATTER_SCRIPT)
		
		rigid_body.global_transform = visual_mesh.global_transform
		
		scene_root.add_child(rigid_body)
		
	
	__log_("end of fully_create_rigid_body_from_mesh_instance")


static func create_rigid_body_from_mesh_instance(
	mesh_instance: MeshInstance3D,
	physics_config: RigidPhysicsConfig = null,
	use_geometry_center_for_mass: bool = true,
	clean: bool = true,
	simplify: bool = false
) -> RigidBody3D:
	if not mesh_instance or not mesh_instance.mesh:
		__log_error("Invalid MeshInstance3D or missing mesh", "", "return null", mesh_instance)
		return null

	if not physics_config:
		physics_config = RigidPhysicsConfig.new()
	
	__log_("Creating rigid body from:", mesh_instance.name, "| use_geometry_center_for_mass:", use_geometry_center_for_mass, "| config:", physics_config)
	__log_("Original mesh global_position:", mesh_instance.global_position)
	
	var rigid_body := RigidBody3D.new()
	rigid_body.global_transform = mesh_instance.global_transform
	
	_setup_mesh(rigid_body, mesh_instance, use_geometry_center_for_mass)
	
	if not _create_collision_shape(
		rigid_body,
		mesh_instance,
		clean,
		simplify
	):
		rigid_body.queue_free()
		return null
	
	_apply_physics_config(rigid_body, physics_config)
	_setup_collision_layers(rigid_body)

	__log_("Rigid body created successfully for:", mesh_instance.name)
	return rigid_body


static func _setup_mesh(
	rigid_body: RigidBody3D,
	mesh_instance: MeshInstance3D,
	use_geometry_center: bool
) -> void:
	# (flags=0: just mesh and materials, no signals/groups/scripts)
	var new_mesh := mesh_instance.duplicate(0)
	rigid_body.add_child(new_mesh)
	new_mesh.transform = Transform3D.IDENTITY
	new_mesh.skeleton = NodePath("")
	new_mesh.extra_cull_margin = max(mesh_instance.extra_cull_margin, 16.0)
	new_mesh.cast_shadow = mesh_instance.cast_shadow
	var geometry_center := Vector3.ZERO
	if use_geometry_center:
		var mesh_aabb := mesh_instance.mesh.get_aabb()
		geometry_center = mesh_aabb.get_center()
		
		rigid_body.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		rigid_body.center_of_mass = geometry_center
		
		__log_("  Mesh AABB center:", geometry_center, "| CoM set to geometry center")
	else:
		__log_("  Using default center of mass")
	

static func _create_collision_shape(
	rigid_body: RigidBody3D,
	mesh_instance: MeshInstance3D,
	clean: bool = true,
	simplify: bool = false
) -> bool:
	var convex_shape := mesh_instance.mesh.create_convex_shape(clean, simplify)
	if not convex_shape:
		__log_error("Failed to create convex shape from mesh", "", "return null", mesh_instance)
		return false
	
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = convex_shape
	rigid_body.add_child(collision_shape)
	
	__log_("  Collision shape created at origin")
	return true


static func _apply_physics_config(rigid_body: RigidBody3D, physics_config: RigidPhysicsConfig) -> void:
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
	return "RigidBodyUtils"


static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.msg_raw(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())


# endregion
