extends Node3D


# recursively sets collision layer and mask for all CSG nodes in the tree
func _set_collision_recursive(node):
	if node is CSGBox3D or node is CSGTorus3D or node is CSGCylinder3D:
		node.collision_layer = Collision.Layers.ENVIRONMENT_COL
		node.collision_mask = Collision.Mask.ENVIRONMENT_COL_MASK
		print_.prefix("Collision", "Set collision layer and mask for CSGBox3D: " + node.name)
	# do not traverse children if node is Character3D
	if node is CharacterBody3D:
		return
	for child in node.get_children():
		_set_collision_recursive(child)

func _ready():
	_set_collision_recursive(self)
