@tool
extends EditorScenePostImport


## DOCS
## what should be in blender tree:
##    - collection which starts with '-col'. Example: '--collisions-columns--'
##    - It contains objects with names equal to main meshes.
##    - See 'auto collision workflow' in blender bible. It automates the process
## Export setup: 
##    - preserve collection structure 
## NOTE: script needs further polishing
## NOTE: as always, apply rot/scale in blender


func _post_import(scene: Node) -> Node:
	__log_pi.start_()

	PICollisionReparent.reparent_collisions(scene)

	__log_pi.end_()
	
	return scene
