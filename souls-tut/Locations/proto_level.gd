extends Node3D


# code in ready which takes all CSGBox3D node descendants and assignes Collision.layer and Mask
func _ready():
	for child in get_children():
		if child is CSGBox3D or child is CSGTorus3D or child is CSGCylinder3D:
			child.collision_layer = Collision.Layers.ENVIRONMENT_COL
			child.collision_mask = Collision.Mask.ENVIRONMENT_COL
			print_.prefix("Collision", "Set collision layer and mask for CSGBox3D: " + child.name)
