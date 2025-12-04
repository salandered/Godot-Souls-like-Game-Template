extends Node3D

func _ready() -> void:
	# prints("~~ready of shattered column")
	for shatter: RigidBody3D in get_descendants.rigid_bodies(self):
		shatter.mass = 10.0
		shatter.gravity_scale = 2.0
		shatter.collision_layer = Collision.Layers.ITEM_COL
		shatter.collision_mask = Collision.Masks.ITEM_COL_MASK
