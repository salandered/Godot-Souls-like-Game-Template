@tool
extends BaseVisuals
class_name EVisuals


func is_player() -> bool:
	return false


func __LOG_B() -> bool:
	return true
	
func __LOG_INDENT() -> int:
	return 0
	

func accept_model_data(_model: PHCharacter):
	for child: MeshInstance3D in get_descendants.mesh_instances_visible(self , true):
		child.skeleton = _model.skeleton.get_path()
