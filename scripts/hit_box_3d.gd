## i d rather call it hurt box

# @tool tells Godot to run the script in editor. 
# change damage_source prop. in the Inspector -> setter func will be called
@tool
@icon("res://assets/icons/hit_box_3d.svg")
class_name HitBox3D extends Area3D

## Emitted when the hit box hits a hurt box.
# define a signal named hit_hurt_box that takes a HurtBox3D as an argument. It reports when the hit box collides with a hurt box.
signal hit_hurt_box(hurt_box: HurtBox3D)

# using binary form
# If the first bit is set (0b10), the damage source is the player.
# If the second bit is set (0b01), the damage source is the mob.
# If both bits are set (0b11), the damage source is both, meaning the hit box will deal damage to any hurt box.
const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b101

## The amount of damage the hit box deals.
@export var damage := 1
## The type of damage that the hit box deals. This helps hurt boxes to filter out damage types.
@export_flags("Player", "Mob") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source
@export_flags("Player", "Mob") var detected_hurtboxes := DAMAGE_SOURCE_MOB: set = set_detected_hurtboxes


func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	# assign the value to the collision_layer property of our Area3D node
	# so our property is a neat shorthand for editing the hitbox's collision layers
	collision_layer = damage_source


func set_detected_hurtboxes(new_value: int) -> void:
	detected_hurtboxes = new_value
	collision_mask = detected_hurtboxes

# Godot calls it when you create an instance of the script, before adding nodes to the scene tree. 
# It's a good place to initialize variables and connect signals that don't depend on accessing 
# other nodes.
# The _ready() function is called after a node has been added to the node tree, 
# and all its children are ready. In contrast, _init() is called for all GDScript objects, 
# even if they are not nodes, and is called on object creation, not when it is added to the tree.
# _init() happens before _ready().
func _init() -> void:
	# set the monitoring and monitorable variables of our Area3D to true to ensure that our hit box, 
	# both detect and be detected by hurt boxes.
	monitoring = true
	monitorable = true
	# Connect Area3D.area_entered sig to a function checking if colliding area is HurtBox3D. 
	# If it is, we emit the hit_hurt_box signal with the hurt box as an argument.
	area_entered.connect(func _on_area_entered(area: Area3D) -> void:
		if area is HurtBox3D:
			hit_hurt_box.emit(area)
	)
