@tool
extends EditorScenePostImport

const PHYSICS_ROOT_PREFIXES = ["--col", "-- col", "-col", "- col"]
const VISUAL_ROOT_NAME = "columns"


## DOCS
## what should be in blender tree:
##    - collection which starts with '-col'. Example: '--collisions-columns--'
##    - It contains objects with names equal to main meshes.
##    - See 'auto collision workflow' in blender bible. It automates the process
## Export setup: 
##    - preserve collection structure 


func _post_import(scene: Node) -> Node:
	__log_begin()

	
	var physics_bodies = {}
	var nodes_to_reparent = []
	
	# FIND COLLISION ROOT 
	var physics_roots: Array
	for prefix in PHYSICS_ROOT_PREFIXES:
		var _root = __find_node_by_prefix(scene, prefix)
		if _root:
			physics_roots.append(_root)
	
	if len(physics_roots) == 0:
		__log_error("FIND_COL_ROOT", "found 0 roots", "_post_import", "script hard stop", "expected prefixes: " + pp.list_(PHYSICS_ROOT_PREFIXES))
		return scene
	elif len(physics_roots) > 1:
		__log_error("FIND_COL_ROOT", "found multiple roots", "_post_import", "script hard stop", "roots: " + str(physics_roots), "expected prefixes: " + pp.list_(PHYSICS_ROOT_PREFIXES))
		return scene
	var physics_root = physics_roots[0]
	
	__log_("FIND_COL_ROOT", "  > Found physics root: " + physics_root.name)
	__log_("FIND_COL_ROOT", "  > Physics root position: " + str(physics_root.position))
	
	# Populate dictionary with Static bodies
	for body in physics_root.get_children():
		if body is StaticBody3D:
			var has_collision = false
			for child in body.get_children():
				if child is CollisionShape3D:
					has_collision = true
					break
			if not has_collision:
				__log_error("POPULATE_BODIES", "physics body has no CollisionShape3D", "validating bodies", "script hard stop", "body: " + body.name)
				return scene
			var normalized_name = ___normalise_node_name(body.name)
			physics_bodies[normalized_name] = body
			__log_("POPULATE_BODIES", "  > Found physics body: " + body.name + " (normalized: " + normalized_name + ") at position: " + str(body.position))
	
	__log_("POPULATE_BODIES", "  > Total physics bodies: " + str(physics_bodies.size()))
	
	# FIND MATCHING MESHES
	for child in scene.get_children():
		if child != physics_root:
			__find_matching_meshes(child, physics_bodies, nodes_to_reparent)
	
	# REPARENT
	if nodes_to_reparent.is_empty():
		__log_("MATCH_MESHES", "  > No matching meshes found to reparent.")
	else:
		__log_("MATCH_MESHES", "\n  > Found " + str(nodes_to_reparent.size()) + " matches. Starting reparent...")
		
	var matched_bodies = {}
	for item in nodes_to_reparent:
		var normalized_name = ___normalise_node_name(item.body.name)
		matched_bodies[normalized_name] = true
		perform_reparent(item.mesh, item.body)
	
	# all collisions matched?
	for body_name in physics_bodies:
		if not matched_bodies.has(body_name):
			__log_error("MATCH_CHECK", "no mesh found for physics body", "collision matching", "continuing without match", "body: " + body_name)
	

	# FLATTEN
	flatten_physics_root(physics_root)
	
	
	# --- Cleanup of empty Node3D ---
	__log_("CLEANUP", "\n=== CLEANUP ===")
	cleanup_empty_nodes(scene)

	__log_end()
	
	return scene


## recursive
func __find_node_by_prefix(node: Node, prefix: String) -> Node:
	if node.name.begins_with(prefix):
		return node
	for child in node.get_children():
		var found = __find_node_by_prefix(child, prefix)
		if found:
			return found
			
	return null


## recursive
func __find_matching_meshes(node: Node, physics_bodies: Dictionary, nodes_to_reparent: Array) -> void:
	if node is MeshInstance3D:
		var normalized_name = ___normalise_node_name(node.name)
		if physics_bodies.has(normalized_name):
			nodes_to_reparent.append({"mesh": node, "body": physics_bodies[normalized_name]})
	
	# Snapshot children before recursing to avoid issues with tree modification
	var children = node.get_children()
	for child in children:
		__find_matching_meshes(child, physics_bodies, nodes_to_reparent)


func perform_reparent(visual_mesh: MeshInstance3D, physics_body: StaticBody3D) -> void:
	__log_("REPARENT", "\n=== REPARENTING: " + visual_mesh.name + " ===")
	
	# Store the physics body's LOCAL position (it's already correct!)
	var body_local_pos = physics_body.position
	__log_("REPARENT", "  [BEFORE] Physics body local pos: " + str(body_local_pos))
	__log_("REPARENT", "  [BEFORE] Visual mesh local pos: " + str(visual_mesh.position))
	

	if visual_mesh.mesh == null:
		__log_error("REPARENT", "mesh instance has no mesh resource", "perform_reparent", "script hard stop", "mesh name: " + visual_mesh.name)
		return
	# Remove visual mesh from old parent
	visual_mesh.get_parent().remove_child(visual_mesh)
	
	# Add visual mesh to physics body
	physics_body.add_child(visual_mesh)

	if physics_body.owner == null:
		__log_error("REPARENT", "physics body has no owner", "perform_reparent", "script hard stop", "body: " + physics_body.name)
		return
	visual_mesh.owner = physics_body.owner
	
	# Reset visual mesh to identity (it's now a child of the body)
	visual_mesh.transform = Transform3D.IDENTITY
	__log_("REPARENT", "  [AFTER] Visual mesh local pos: " + str(visual_mesh.position))
	
	# Physics body keeps its local position unchanged
	__log_("REPARENT", "  [AFTER] Physics body local pos: " + str(physics_body.position))


func flatten_physics_root(physics_root: Node) -> void:
	__log_("FLATTEN", "\n=== FLATTENING PHYSICS ROOT ===")
	var physics_parent = physics_root.get_parent()
	__log_("FLATTEN", "  > Physics root parent: " + physics_parent.name)
	
	var bodies_to_move = []
	for body in physics_root.get_children():
		if body is StaticBody3D:
			bodies_to_move.append(body)
	
	if bodies_to_move.is_empty():
		__log_("FLATTEN", "  > No bodies to flatten.")
		return
	
	for body in bodies_to_move:
		__log_("FLATTEN", "  > Moving body: " + body.name)
		var body_local_pos = body.position
		
		physics_root.remove_child(body)
		physics_parent.add_child(body)
		if physics_parent.owner == null:
			__log_error("REPARENT", "physics_parent has no owner", "flatten_physics_root", "script hard stop", "physics_parent: " + physics_parent.name)
			return
		body.owner = physics_parent.owner
		body.position = body_local_pos
	
	__log_("FLATTEN", "  > Removing physics root: " + physics_root.name)
	physics_parent.remove_child(physics_root)
	physics_root.free()


func cleanup_empty_nodes(node: Node) -> void:
	var children_to_check = node.get_children().duplicate()
	
	for child in children_to_check:
		cleanup_empty_nodes(child)
	
	if node.get_class() == "Node3D" and node.get_child_count() == 0:
		if node.get_parent():
			__log_("CLEANUP", "  > Cleaning up empty Node3D: " + node.name)
			node.get_parent().remove_child(node)
			node.free()


## HELPERS and LOGS

func ___normalise_node_name(name_: String) -> String:
	return name_.strip_edges().to_lower()


func __log_error(prefix: String, what: String, where: String, fallback: String, ...context: Array):
	var _msg = "Problem: %s. Where: '%s'. Fallback: %s" % [what, where, fallback]
	if not context.is_empty():
		_msg += " Details: " + pp.list_(context)
	print(pp.s(em.warn_x2, pp.in_sq(prefix)), _msg)

func __log_(prefix, ...parts: Array):
	print(pp.in_sq(prefix), pp.list_(parts))


func __log_begin():
	__log_("", "\n========================================")
	__log_("", "=== POST-IMPORT SCRIPT STARTED ===")
	__log_("", "========================================\n")


func __log_end():
	__log_("", "\n========================================")
	__log_("", "=== POST-IMPORT SCRIPT COMPLETE ===")
	__log_("", "========================================\n")
