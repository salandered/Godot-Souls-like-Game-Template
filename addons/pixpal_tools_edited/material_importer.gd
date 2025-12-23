@tool
extends EditorScenePostImportPlugin

var pixpal_material: ShaderMaterial

func _pre_process(scene: Node) -> void:
	iterate(scene)

# Loops through each imported Node looking for PixPal materials to replace with our version.
func iterate(node: Node) -> void:
	# We only care about MeshInstances
	if node is ImporterMeshInstance3D:
		var mesh: ImporterMesh = node.mesh

		# Loop through mesh materials looking for a PixPal
		for index in mesh.get_surface_count():
			var material_name: String = mesh.get_surface_material(index).resource_name

			# Material found. Replace with our version
			# - edited: was .endswith
			# - edited: skip feature
			if "pixpal" in material_name.to_lower() and "-skipreimp" not in material_name:
				print("\n🎨 PixPal mat found. replacing with godot version 🎨\n")
				mesh.set_surface_material(index, get_pixpal_material())

	for child in node.get_children():
		iterate(child)

# Returns the PixPal ShaderMaterial. Caches for faster retrieval.
func get_pixpal_material() -> ShaderMaterial:
	if not pixpal_material:
		pixpal_material = load("res://addons/pixpal_tools_edited/PixPal/Materials/M_PixPal.tres")

	return pixpal_material
