extends RefCounted
class_name PushRigidBodies


## DOCS
## "By default, a CharacterBody2D moved with move_and_slide() or move_and_collide() will not push
## any RigidBody2D it collides with. The rigid body doesn’t react at all, and behaves just like a StaticBody"
## See: https://kidscancode.org/godot_recipes/4.x/physics/character_vs_rigid/index.html


## meant to be called nearby the move_and_slide (each frame).
static func push_rigid_bodies(character: BaseCharacter, push_force: float = 4.0):
	for _number_of_items_body_collided_with in character.get_slide_collision_count():
		var collision = character.get_slide_collision(_number_of_items_body_collided_with)
		if collision.get_collider() is RigidBody3D:
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)
