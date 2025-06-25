class_name Mob3D extends CharacterBody3D

## The mob's skin. This is necessary to play animations.
@export var skin: MobSkin3D = null
## The mob's hurtbox. This is necessary for managing damage.
@export var hurt_box: HurtBox3D = null

# You can also use the annotation @export_group to group the properties into a collapsible section.
@export_category("Detection")
## Determines how far the mob can detect the player.
@export var vision_range := 7.0
## Determines the angle in radians that the mob can detect the player.
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var vision_angle := PI / 4.0

# added by myself
@export_range(0, 100.0, 0.1) var gravity := 20.0
