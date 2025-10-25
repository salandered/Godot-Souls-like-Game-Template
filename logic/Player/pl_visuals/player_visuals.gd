@tool
extends BaseVisuals
class_name PlayerVisuals


# TODO: flying head without eyes
func accept_model_data(_model: PlayerModel):
	for child: MeshInstance3D in get_descendants.mesh_instances(self, true):
		child.skeleton = _model.skeleton.get_path()
