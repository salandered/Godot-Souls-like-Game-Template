@tool
extends BaseVisuals
class_name PlayerVisuals


func is_player() -> bool:
	return true


func __LOG_B() -> bool:
	return true
	
func __LOG_INDENT() -> int:
	return 0
	

# TODO: flying head without eyes
func accept_model_data(_model: Princess):
	var a: String = "a"
	a.contains("a")
	for child: MeshInstance3D in get_descendants.mesh_instances_visible(self, true):
		child.skeleton = _model.skeleton.get_path()
