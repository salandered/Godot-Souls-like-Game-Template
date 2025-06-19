## i d rather call it hit box

@tool
@icon("res://=assets/icons/hurt_box_3d.svg")
class_name HurtBox3D extends Area3D

## emit a signal named took_hit when it detects a collision with a HitBox3D node
signal took_hit(hit_box: HitBox3D)

const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10

## Controls which damage source the hurt box can take damage from.
## This changes the node's collision mask so it will only collide with a matching damage source.
@export_flags("Player", "Mob") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source
@export_flags("Player", "Mob") var hurtbox_type := DAMAGE_SOURCE_PLAYER: set = set_hurtbox_type

# Making the damage_source property affect the collision mask 
# while the hit box's damage source affects its collision layer 
# allows hit and hurt boxes with at least one matching damage sources to detect each other.

# almost the same as in hit_box, but we swap what changes the collision_mask and collision_layer 
# properties. # => hurt box will detect hit boxes with matching damage sources.
func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_mask = damage_source

func set_hurtbox_type(new_value: int) -> void:
	hurtbox_type = new_value
	collision_layer = hurtbox_type

func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(func _on_area_entered(area: Area3D) -> void:
		if area is HitBox3D:
			took_hit.emit(area)  # takes a HitBox3D as an argument
	)
