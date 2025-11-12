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
		var normalized_name = node.name.strip_edges().to_lower()
		if physics_bodies.has(normalized_name):
			nodes_to_reparent.append({"mesh": node, "body": physics_bodies[normalized_name]})
			return

	for child in node.get_children():
		__find_matching_meshes(child, physics_bodies, nodes_to_reparent)


func perform_reparent(visual_mesh: MeshInstance3D, physics_body: StaticBody3D) -> void:
	__log_("\n=== REPARENTING: " + visual_mesh.name + " ===")
	
	# Store the physics body's LOCAL position (it's already correct!)
	var body_local_pos = physics_body.position
	__log_("  [BEFORE] Physics body local pos: ", body_local_pos)
	__log_("  [BEFORE] Visual mesh local pos: ", visual_mesh.position)
	
	# Remove visual mesh from old parent
	visual_mesh.get_parent().remove_child(visual_mesh)
	
	# Add visual mesh to physics body
	physics_body.add_child(visual_mesh)
	visual_mesh.owner = physics_body.owner
	
	# Reset visual mesh to identity (it's now a child of the body)
	visual_mesh.transform = Transform3D.IDENTITY
	__log_("  [AFTER] Visual mesh local pos: ", visual_mesh.position)
	
	# Physics body keeps its local position unchanged
	__log_("  [AFTER] Physics body local pos: ", physics_body.position)


func cleanup_empty_nodes(node: Node) -> void:
	var children_to_check = node.get_children().duplicate()
	
	for child in children_to_check:
		cleanup_empty_nodes(child)
	
	if node.get_class() == "Node3D" and node.get_child_count() == 0:
		if node.get_parent():
			__log_("CLEANUP", "  > Cleaning up empty Node3D: " + node.name)
			node.get_parent().remove_child(node)
			node.free()


func _post_import(scene: Node) -> Node:
	__log_("\n========================================")
	__log_("=== POST-IMPORT SCRIPT STARTED ===")
	__log_("========================================\n")
	
	var physics_bodies = {}
	var nodes_to_reparent = []
	
	# FIND COLLISION ROOT 
	var physics_roots: Array
	for prefix in PHYSICS_ROOT_PREFIXES:
		var _root = __find_node_by_prefix(scene, prefix)
		if _root:
			physics_roots.append(_root)
	
	if len(physics_roots) == 0:
		__log_("  ! ERROR: Could not find physics root node (starting with '" + pp.list_(PHYSICS_ROOT_PREFIXES) + "').")
		return scene
	elif len(physics_roots) > 1:
		__log_("  ! ERROR: Found several physics root nodes. We need one for consistent behaviour. " \
				+ ("starting with " + pp.list_(PHYSICS_ROOT_PREFIXES)) \
				+ str(physics_roots))
		return scene
	var physics_root = physics_roots[0]
	
	__log_("  > Found physics root: " + physics_root.name)
	__log_("  > Physics root position: ", physics_root.position)
	
	# Populate dictionary with Static bodies
	for body in physics_root.get_children():
		if body is StaticBody3D:
			var normalized_name = ___normalise_node_name(body.name)
			physics_bodies[normalized_name] = body
			__log_("  > Found physics body: " + body.name + " (normalized: " + normalized_name + ") at position: ", body.position)
	
	__log_("  > Total physics bodies: " + str(physics_bodies.size()))
	
	# FIND MATCHING MESHES
	for child in scene.get_children():
		if child != physics_root:
			__find_matching_meshes(child, physics_bodies, nodes_to_reparent)
	
	# REPARENT
	if nodes_to_reparent.is_empty():
		__log_("  > No matching meshes found to reparent.")
	else:
		__log_("\n  > Found " + str(nodes_to_reparent.size()) + " matches. Starting reparent...")
		
	var matched_bodies = {}
	for item in nodes_to_reparent:
		var normalized_name = item.body.name.strip_edges().to_lower()
		matched_bodies[normalized_name] = true
		perform_reparent(item.mesh, item.body)
	
	# all collisions matched?
	for body_name in physics_bodies:
		if not matched_bodies.has(body_name):
			__log_(em.warn + " ! WARNING: No mesh found for physics body: " + body_name)
	

	# FLATTEN
	flatten_physics_root(physics_root)
	
	
	# --- Cleanup of empty Node3D ---
	__log_("\n=== CLEANUP ===")
	cleanup_empty_nodes(scene)
	
	__log_("\n========================================")
	__log_("=== POST-IMPORT SCRIPT COMPLETE ===")
	__log_("========================================\n")
	
	return scene


func flatten_physics_root(physics_root: Node) -> void:
	__log_("\n=== FLATTENING PHYSICS ROOT ===")
	var physics_parent = physics_root.get_parent()
	__log_("  > Physics root parent: " + physics_parent.name)
	
	var bodies_to_move = []
	for body in physics_root.get_children():
		if body is StaticBody3D:
			bodies_to_move.append(body)
	
	if bodies_to_move.is_empty():
		__log_("  > No bodies to flatten.")
		return
	
	for body in bodies_to_move:
		__log_("  > Moving body: " + body.name)
		var body_local_pos = body.position
		
		physics_root.remove_child(body)
		physics_parent.add_child(body)
		body.owner = physics_parent.owner
		body.position = body_local_pos
	
	__log_("  > Removing physics root: " + physics_root.name)
	physics_parent.remove_child(physics_root)
	physics_root.free()


## HELPERS

func ___normalise_node_name(name_: String):
	return name_.strip_edges().to_lower()


func __log_error(prefix: String, what: String, where: String, fallback: String, ...context: Array):
	var _msg = "Problem: %s. Where: '%s'. Fallback: %s" % [what, where, fallback]
	if not context.is_empty():
		_msg += " Details: " + pp.list_(context)
	print(pp.s(em.warn_x2, pp.in_sq(prefix)), _msg)

func __log_(prefix, ...parts: Array):
	print(pp.in_sq(prefix), pp.list_(parts))