@tool
extends BaseVisuals
class_name PlayerVisuals


# TODO: flying head without eyes
func accept_model_data(_model: Princess):
	var a: String = "a"
	a.contains("a")
	for child: MeshInstance3D in get_descendants.mesh_instances_visible(self, true):
		child.skeleton = _model.skeleton.get_path()
