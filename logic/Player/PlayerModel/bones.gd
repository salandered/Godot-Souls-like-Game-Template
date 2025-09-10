extends Node3D

@onready var general_skeleton: Skeleton3D = %GeneralSkeleton

func _get_descendants(node: Node) -> Array:
	var descendants := []
	for child in node.get_children():
		if child is BoneAttachment3D:
			descendants.append(child)
		descendants.append_array(_get_descendants(child))
	return descendants

# TODO: flying head without eyes
func accept_bones():
	for child: BoneAttachment3D in _get_descendants(self):
		child.set_external_skeleton(general_skeleton.get_path())
