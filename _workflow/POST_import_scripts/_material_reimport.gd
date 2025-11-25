@tool
extends RefCounted
class_name PIMaterialReimport


static func material_reimport(node: Node):
	_iterate_mesh_instances(node)


static func _iterate_mesh_instances(node: Node):
	if node != null:
		if node is MeshInstance3D:
			__log_pi.info_("MESH", "Found MeshInstance3D", pp.in_q(node.name))
			_process_materials(node)

		for child in node.get_children():
			_iterate_mesh_instances(child)


static func _process_materials(mesh_instance: MeshInstance3D):
	var mesh = mesh_instance.mesh
	
	for i in range(mesh.get_surface_count()):
		var mat = mesh.surface_get_material(i)
		_process_single_surface(mesh, i, mat, mesh_instance.name)


static func _process_single_surface(mesh: Mesh, idx: int, mat: Material, node_name: String):
	if mat == null:
		__log_pi.info_("VALIDATION", "No material on Surface %d" % idx, node_name)
		return

	if not (mat is BaseMaterial3D):
		__log_pi.info_("VALIDATION", "Not StandardMaterial3D (Surface %d)" % idx, pp.in_q(mat.resource_name))
		return


	# If the material already has a file path starting with "res://", 
	# it means the user manually assigned "Use External" in the Import Settings.
	if mat.resource_path.begins_with("res://"):
		__log_pi.info_("SKIP❎ 1", "User assigned external material (Use External)", mat.resource_path)
		return
	# ----------------------------------------------------

	var mat_resource_name = mat.resource_name
	
	for ignore_str in PIConfig.MAT_IGNORE_LIST:
		if ignore_str in mat_resource_name.to_lower():
			__log_pi.info_("SKIP❎ 1", "Ignored by Config", mat_resource_name)
			return

	var save_path = _get_mat_save_path(mat_resource_name)
	__log_pi.info_("PATH_CALC", "EnemyCameraTarget Path Calculated for mat", pp.in_q(mat_resource_name), ": ", pp.in_q(save_path))


	if FileAccess.file_exists(save_path):
		var loaded_mat = load(save_path)
		mesh.surface_set_material(idx, loaded_mat)
		
		__log_pi.info_("📁 1", "✅️ File with this material already exists in shared-mats. It's assigned to mat", pp.in_q(mat_resource_name))
		return

	# If we are here, it's a new material
	_fix_rough_and_metallic(mat)

	__log_pi.info_("SAVE_NEW", "Saving new material...", save_path)
	
	# Set the path on the resource itself so Godot knows where it lives
	mat.resource_path = save_path
	var err = ResourceSaver.save(mat, save_path)
	
	if err == OK:
		__log_pi.info_("SAVE_NEW", "✅️ Saved Successfully to", pp.in_q(save_path))
		# Re-assign the saved material to the mesh to ensure the link is firm
		# (Reloading from disk confirms the file is valid)
		var reloaded_mat = load(save_path)
		mesh.surface_set_material(idx, reloaded_mat)
	else:
		__log_pi.error_("SAVE_NEW", "Failed to save material", save_path, "Keeping temporary version", "Error Code: %s" % err)


static func _get_mat_save_path(mat_name: String) -> String:
	var lower_name = mat_name.to_lower()
	var folder = "unsorted"
	
	for target_folder in PIConfig.SUBFOLDER_RULES:
		for keyword in PIConfig.SUBFOLDER_RULES[target_folder]:
			if keyword in lower_name:
				folder = target_folder
				break
		# If we found a match, stop checking other folders
		if folder != "unsorted":
			break
	
	# Construct: res://path/folder/name_Reimp.tres
	return "%s%s/%s%s.tres" % [PIConfig.BASE_MAT_PATH, folder, mat_name, PIConfig.REIMP_SUFFIX]

static func _fix_rough_and_metallic(mat: BaseMaterial3D):
	var __prefix = "⛰️/🔩 4"
	__log_pi.info_("⛰️/🔩", "Applying fixes to new material", mat.resource_name)

	if mat.roughness_texture:
		var path = mat.roughness_texture.resource_path
		if "_rough" in path:
			if mat.roughness_texture_channel != BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE:
				__log_pi.info_(__prefix, "Roughness: Channel %s -> GRAYSCALE (4)" % mat.roughness_texture_channel)
				mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE

	if mat.metallic_texture:
		var path = mat.metallic_texture.resource_path
		if "_rough" in path:
			__log_pi.info_(__prefix, "✳️✳️ Roughness map in Metallic slot", mat.resource_name, "Removing Texture", path)
			mat.metallic_texture = null
			mat.metallic = 0.0

	# If we have no metallic texture now, try to find one
	if mat.metallic_texture == null:
		_try_find_metallic_texture(mat)


static func _try_find_metallic_texture(mat: BaseMaterial3D):
	var __prefix = "🔎🔩 6"
	var ref_path = ""
	var suffixes_to_replace = []
	
	# Determine where to look based on existing textures
	if mat.roughness_texture:
		ref_path = mat.roughness_texture.resource_path
		suffixes_to_replace = PIConfig.ROUGH_SUFFIXES
		__log_pi.info_(__prefix, "Using Roughness as reference", ref_path.get_file())
	elif mat.albedo_texture:
		ref_path = mat.albedo_texture.resource_path
		suffixes_to_replace = PIConfig.DIFF_SUFFIXES
		__log_pi.info_(__prefix, "Using Albedo as reference", ref_path.get_file())
	
	if ref_path == "":
		__log_pi.info_(__prefix, "No reference texture found (Roughness/Albedo). Finding metallic stopped", "✖️")
		return

	var dir = ref_path.get_base_dir()
	var filename = ref_path.get_file()
	var targets = PIConfig.METAL_SUFFIXES
	var found_match = false
	
	for suffix_src in suffixes_to_replace:
		if suffix_src in filename:
			for suffix_dst in targets:
				var new_name = filename.replace(suffix_src, suffix_dst)
				var guess_path = dir + "/" + new_name
				
				if FileAccess.file_exists(guess_path):
					__log_pi.info_(__prefix, "FOUND MATCH! Auto-assigning metallic", new_name)
					mat.metallic_texture = load(guess_path)
					mat.metallic = 1.0
					mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
					found_match = true
					return
				else:
					pass
					# __log_pi.info_(__prefix, "Candidate check failed (File not found)", new_name)

	if not found_match:
		__log_pi.info_(__prefix, "No matching metallic texture found. ✖️")
