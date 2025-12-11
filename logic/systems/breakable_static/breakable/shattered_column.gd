extends Node3D

const DARK_CRATE_PH_MAT_COPIED = preload("uid://je08c3ggwy7m")

func _ready() -> void:
	var count: int = 0
	for shatter: RigidBody3D in get_descendants.rigid_bodies(self):
		shatter.mass = 5.0
		shatter.gravity_scale = 2.0
		shatter.collision_layer = Collision.Layers.ITEM_COL
		shatter.collision_mask = Collision.Masks.ITEM_COL_MASK
		# shatter.physics_material_override = DARK_CRATE_PH_MAT_COPIED
		count += 1
		
	prints("~~///////////ready of shattered column", count, "were initialised")
