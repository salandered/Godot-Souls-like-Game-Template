extends RigidBody3D


func _ready() -> void:
	collision_layer = Collision.Layers.ITEM_COL
	collision_mask = Collision.Masks.ITEM_COL_MASK
