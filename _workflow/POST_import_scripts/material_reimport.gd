@tool
extends EditorScenePostImport

## Material Reimport Post-Process Script
##
## Runs during GLB import to extract and persist materials as external .tres files.

## Automates material processing for imported meshes.
## - Recursively scans nodes to standardize materials, fixes texture channels,
## - auto-discovers missing metallic maps
## - centralizes material storage for reuse.

## The mesh.surface_set_material() call during _post_import modifies the temporary
## mesh data before Godot caches it, creating a direct reference to external materials
## that bypasses the Import Settings UI.
##
## Material references exist in the imported mesh binary data, not in .import settings. (NOTE: Needs verifying)
## NOTE: In import window changes can't be seen.


func _post_import(scene: Node) -> Node:
	__log_script.start_()

	PIMaterialReimport.material_reimport(scene)

	__log_script.end_()
	
	return scene
