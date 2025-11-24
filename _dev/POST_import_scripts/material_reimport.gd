@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Node:
	__log_pi.start_()

	PIMaterialReimport.material_reimport(scene)

	__log_pi.end_()
	
	return scene
