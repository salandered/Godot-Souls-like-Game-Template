@tool
extends EditorScenePostImport

const BASE_MAT_PATH = "res://-assets-/materials-shared/"


var COL_REPARENT: bool = true
var MATERIAL_REIMPORT: bool = true

func _post_import(scene: Node) -> Node:
	__log_pi.start_()


	__log_pi.info_("REPARENT_COLLISIONS", "---------")
	PICollisionReparent.reparent_collisions(scene)


	__log_pi.info_("MATERIAL_REIMPORT", "---------")
	PIMaterialReimport.material_reimport(scene)


	__log_pi.info_("CLEANUP", "\n=== CLEANUP ===")
	PICleanupEmptyNodes.cleanup_empty_nodes(scene)

	__log_pi.end_()

	return scene
