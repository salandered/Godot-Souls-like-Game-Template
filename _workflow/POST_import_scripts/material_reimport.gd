@tool
extends EditorScenePostImport

## Material Reimport Post-Process Script
##
## Runs during GLB import to extract and persist materials as external .tres files.
## The mesh.surface_set_material() call during _post_import modifies the temporary
## mesh data before Godot caches it, creating a direct reference to external materials
## that bypasses the Import Settings UI.
##
## Note: Material references exist in the imported mesh binary data, not in .import settings.
## NOTE: u cant see this links in UI of import settings (Use External looks looks like false)

func _post_import(scene: Node) -> Node:
	__log_script.start_()

	PIMaterialReimport.material_reimport(scene)

	__log_script.end_()
	
	return scene
