class_name Area3DUtils
extends RefCountedStaticLogger


## Calculates the contact point between a generic generic Area/Body and the world.
## Note: This queries the physics space, so it detects the "best" contact available.
static func get_area_contact_point(my_area: Area3D, target_area: Area3D) -> Vector3:
	# 1. Get the shape and transform from the attacker
	var my_collider = _find_first_collision_shape(my_area)
	if not my_collider:
		return Vector3.INF
		
	# 2. Prepare a Physics Query
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = my_collider.shape
	params.transform = my_collider.global_transform
	params.collide_with_areas = true
	params.collide_with_bodies = false # Ignore walls/floor for this check
	
	# Optimization: Only check against the specific enemy's layer to avoid hitting walls
	params.collision_mask = target_area.collision_layer
	
	# 3. Ask the Physics Server for contact info
	var space_state := my_area.get_world_3d().direct_space_state
	var result := space_state.get_rest_info(params)
	
	if not result.is_empty():
		return result["point"] # Returns the exact contact position in Global space
		
	return Vector3.INF


## Helper to find the first active collision shape
static func _find_first_collision_shape(node: Node) -> CollisionShape3D:
	for child in node.get_children():
		if child is CollisionShape3D and not child.disabled:
			return child
	return null


# region: __LOGS

static func pp_name() -> String:
	return "Area3DUtils"

static func __LOG_B() -> bool:
	return true

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion