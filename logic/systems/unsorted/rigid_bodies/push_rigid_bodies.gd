extends RefCounted
class_name PushRigidBodies


## DOCS
## "By default, a CharacterBody2D moved with move_and_slide() or move_and_collide() will not push
## any RigidBody2D it collides with. The rigid body doesn’t react at all, and behaves just like a StaticBody"
## See: https://kidscancode.org/godot_recipes/4.x/physics/character_vs_rigid/index.html


## meant to be called nearby the move_and_slide (each frame).
static func push_rigid_bodies(character: BaseCharacter, push_force: float = 4.0):
	for _number_of_items_body_collided_with in character.get_slide_collision_count():
		var collision := character.get_slide_collision(_number_of_items_body_collided_with)
		if collision.get_collider() is RigidBody3D:
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)


static func push_nearby_rigid_bodies(character: BaseCharacter, radius: float = 3.0, push_force: float = 200.0):
	var space_state := character.get_world_3d().direct_space_state
	
	# create sphere query
	var query := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	query.shape = sphere
	query.transform = Transform3D(Basis(), character.global_position)
	query.collision_mask = Collision.Layers.ITEM_COL
	
	# find all rigid bodies in radius
	var intersected_objects := space_state.intersect_shape(query)
	
	for item: Dictionary in intersected_objects:
		var body = item.collider
		if body is RigidBody3D:
			var direction = (body.global_position - character.global_position).normalized()
			# Add upward component for more dramatic effect
			direction.y += 0.3
			direction = direction.normalized()
			
			var distance = character.global_position.distance_to(body.global_position)
			# Falloff: closer objects get pushed harder
			var falloff = 1.0 - (distance / radius)
			
			body.apply_central_impulse(direction * push_force * falloff)