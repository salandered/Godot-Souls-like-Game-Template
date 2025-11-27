@tool
extends RefCounted
class_name PICollisionReparent


## DOCS
## what should be in blender tree:
##    - collection which starts with '-col'. Example: '--collisions-columns--'
##    - It contains objects with names equal to main meshes.
##    - See 'auto collision workflow' in blender bible. It automates the process
## Export setup: 
##    - preserve collection structure 
## NOTE: script needs further polishing
## NOTE: as always, apply rot/scale in blender


static func reparent_collisions(scene):
	var name_to_static_object = {}

	## List[Dict["mesh": MeshInstance3D, "body": StaticBody3D]]
	var meshes_to_reparent = []
	
	# FIND COLLISION GROUP (collection in blender)
	var col_collections: Array
	for prefix in PIConfig.COLLISION_COLLECTION_PREFIXES:
		var _col_collection = __find_node_by_prefix(scene, prefix)
		if _col_collection:
			col_collections.append(_col_collection)
	
	if len(col_collections) == 0:
		__log_script.info_("ℹ️ FIND_COL_COLLECTION", "found 0 collections ✖️", "Used prefixes for search:", pp.list_(PIConfig.COLLISION_COLLECTION_PREFIXES))
		return
	elif len(col_collections) > 1:
		__log_script.error_("FIND_COL_COLLECTION", "found multiple collections", "_post_import",
			"script hard stop", "collections:", col_collections, "expected prefixes:", pp.list_(PIConfig.COLLISION_COLLECTION_PREFIXES))
		return
	var col_collection: Node3D = col_collections[0]
	
	__log_script.info_("FIND_COL_COLLECTION", "> Found col collection:", col_collection.name)
	__log_script.info_("FIND_COL_COLLECTION", "> Its position:", col_collection.position)
	
	# Populate dictionary with Static bodies
	for item in col_collection.get_children():
		if item is StaticBody3D:
			var static_body := item as StaticBody3D
			var has_collision = false
			for child in static_body.get_children():
				if child is CollisionShape3D:
					has_collision = true
					break
			if not has_collision:
				__log_script.error_("POPULATE_BODIES", "static_body has no CollisionShape3D", "validating bodies", "script hard stop", "body:" + static_body.name)
				return
			var normalized_name = ___normalise_node_name(static_body.name)
			name_to_static_object[normalized_name] = static_body
			__log_script.info_("POPULATE_BODIES", "> Found static body:", static_body.name, pp.in_sq("normalized:" + normalized_name), "at position:", static_body.position)
	
	__log_script.info_("POPULATE_BODIES", "> Total static bodies under collision collection:", name_to_static_object.size())
	
	# FIND MATCHING MESHES
	for child in scene.get_children():
		if child != col_collection:
			__find_matching_meshes(child, name_to_static_object, meshes_to_reparent)
	
	# REPARENT (move body then add mesh)
	if meshes_to_reparent.is_empty():
		__log_script.info_("MATCH_MESHES", "> No matching meshes found to reparent.")
	else:
		__log_script.info_("MATCH_MESHES", "\n  > Found", meshes_to_reparent.size(), "matches. Starting reparent...")
		
	var meshes_with_static_match_found = {}
	for dict_item: Dictionary in meshes_to_reparent:
		var normalized_name = ___normalise_node_name(dict_item["body"].name)
		meshes_with_static_match_found[normalized_name] = true
		perform_combined_reparent(dict_item["mesh"], dict_item["body"], col_collection)
	
	# check that all collisions matched
	for static_body_name: String in name_to_static_object:
		if not meshes_with_static_match_found.has(static_body_name):
			__log_script.error_("MATCH_CHECK", "no mesh found for static body", "collision matching", "continuing without match", "static body name:", pp.in_q(static_body_name))
	
	# CLEANUP: Remove empty col collection
	if col_collection.get_child_count() == 0:
		__log_script.info_("CLEANUP_COL_COLLECTION", "> Removing col collection:", col_collection.name)
		col_collection.get_parent().remove_child(col_collection)
		col_collection.free()


## recursive
static func __find_node_by_prefix(node: Node, prefix: String) -> Node:
	if node.name.begins_with(prefix):
		return node
	for child in node.get_children():
		var found = __find_node_by_prefix(child, prefix)
		if found:
			return found
			
	return null


## recursive
static func __find_matching_meshes(node: Node, name_to_static_object: Dictionary, meshes_to_reparent: Array) -> void:
	if node is MeshInstance3D:
		var normalized_name = ___normalise_node_name(node.name)
		if name_to_static_object.has(normalized_name):
			meshes_to_reparent.append({"mesh": node, "body": name_to_static_object[normalized_name]})
	
	# Snapshot children before recursing to avoid issues with tree modification
	var children = node.get_children()
	for child in children:
		__find_matching_meshes(child, name_to_static_object, meshes_to_reparent)


static func perform_combined_reparent(visual_mesh: MeshInstance3D, static_body: StaticBody3D, col_collection: Node) -> void:
	var __prefix = "👪 3"
	__log_script.info_(__prefix, "\n=== REPARENTING:", visual_mesh.name, "===")
	
	var body_local_pos = static_body.position
	var mesh_local_pos = visual_mesh.position
	var mesh_parent = visual_mesh.get_parent()
	
	__log_script.info_(__prefix, "[BEFORE] Static body local pos:", body_local_pos)
	__log_script.info_(__prefix, "[BEFORE] Visual mesh local pos:", mesh_local_pos)
	__log_script.info_(__prefix, "[BEFORE] Mesh parent:", mesh_parent.name)
	__log_script.info_(__prefix, "[BEFORE] Body name:", pp.in_q(static_body.name))
	__log_script.info_(__prefix, "[BEFORE] Mesh name:", pp.in_q(visual_mesh.name))
	
	# Calculate the offset between visual mesh and static body
	var offset = mesh_local_pos - body_local_pos
	__log_script.info_(__prefix, "[OFFSET] Calculated offset:", offset)
	
	if visual_mesh.mesh == null:
		__log_script.error_(__prefix, "mesh instance has no mesh resource", "perform_combined_reparent", "script hard stop", "mesh name:", visual_mesh.name)
		return
	
	var target_owner = static_body.owner
	if target_owner == null:
		__log_script.error_(__prefix, "static body has no owner", "perform_combined_reparent", "script hard stop", "body:", static_body.name)
		return
	
	# STEP 1: Rename mesh first to avoid name conflict when body is added
	var original_mesh_name = visual_mesh.name
	visual_mesh.name = visual_mesh.name + "_visuals"
	__log_script.info_(__prefix, "[STEP 1] Renamed mesh:", original_mesh_name, "->", visual_mesh.name)
	
	# STEP 2: Move body to mesh's parent (no conflict now)
	static_body.owner = null
	col_collection.remove_child(static_body)
	mesh_parent.add_child(static_body)
	static_body.owner = target_owner
	static_body.position = body_local_pos
	__log_script.info_(__prefix, "[STEP 2] Moved body to:", mesh_parent.name)
	
	# STEP 3: Move mesh under body
	visual_mesh.owner = null
	mesh_parent.remove_child(visual_mesh)
	static_body.add_child(visual_mesh)
	visual_mesh.owner = target_owner
	visual_mesh.position = offset
	__log_script.info_(__prefix, "[STEP 3] Moved mesh under body")
	
	__log_script.info_(__prefix, "[AFTER] Visual mesh local pos:", visual_mesh.position)
	__log_script.info_(__prefix, "[AFTER] Static body local pos:", static_body.position)


static func ___normalise_node_name(name_: String) -> String:
	return name_.strip_edges().to_lower()
