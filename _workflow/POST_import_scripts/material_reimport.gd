@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Node:
	__log_script.start_()

	PIMaterialReimport.material_reimport(scene)

	__log_script.end_()
	
	return scene
