extends RefCounted
class_name Collision

## DOCS
## im not really sure about correct separation. Testing this:
## ENVIRONMENT_COL - terrain, all the static objects. [Real physical] 
##    > StaticBody, All CSG
## ITEM_COL - dynamic objects, like boxes or shatters. 
##    > RigidBody
## PROP_COL - additional logic for interactable items. Currently used in Area3D which checks for breaking the column
##    > Area
## PLAYER_COL/OTHER_CHAR_COL - player/enemies/NPCs. [Real physical]
##    > CharacterBody
## HITBOX_AREA - areas on characters. 
##             NOTE: Probably should be renamed to character body area. 
##                   I think this could be used not only for capturing hits
##    > Area
## WEAPON_AREA - hurt boxes of weapons. 
##    > Area
## 
## NOTE: WHERE TO ASSIGN 
##       Priority is to assign according layers/masks in _ready. 
##		 Also you can batch assign everything in root nodes using get_descendants. 
##       But it will override what was set in _ready by specific scripts!

## TROUBLESHOOTING
# region
## CHECKLIST for any issue
## 	- make sure collision_mask/collision_layer are not overriden for the same object from different places
## ISSUE your character sometimes inexplicably speeding up when pushing a RigidBody
## 	Reason: CharacterBody node has logic to ensure the character stays stationary on moving platforms, 
##          and when you collide into the rigidbody object it ends up being counted as a moving platform. 
## 	        => CharacterBody inherits the velocity of the rigidbody
##  - Go into the "Moving Platform" part of the CharacterBody's node settings, 
## 	  and disable the physics layer you're using for the rigidbody objects. 
## 	  (By default all physics layers are enabled)
## ISSUE: character falls through the collision or get stuck on level from Blender
##  - make sure that face orientation of collision objects in Blender is ok!
##  - also don't use paper thin collision objects
# endregion


## WARNING: Don't change without checking project settings alisases for!
enum Layers {
	ENVIRONMENT_COL = 1 << 0, # bit 0
	PLAYER_COL = 1 << 1, # bit 1
	OTHER_CHAR_COL = 1 << 2, # bit 2
	HITBOX_AREA = 1 << 3, # bit 3
	WEAPON_AREA = 1 << 4, # bit 4 (damage-dealing)
	ITEM_COL = 1 << 5, # bit 5
	PROP_COL = 1 << 6, # bit 6
}

enum Masks {
	# probably ENVIRONMENT_COL_MASK should not contain anything
	ENVIRONMENT_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL, # | Layers.ITEM_COL,
	# not sure of Layers.ITEM_COL for character masks. 
	# for now characters move rigid bodies, but not vice versa
	PLAYER_COL_MASK = Layers.ENVIRONMENT_COL | Layers.OTHER_CHAR_COL, # | Layers.ITEM_COL,
	OTHER_CHAR_COL_MASK = Layers.ENVIRONMENT_COL | Layers.PLAYER_COL | Layers.OTHER_CHAR_COL, # | Layers.ITEM_COL,
	HITBOX_AREA_MASK = Layers.WEAPON_AREA,
	# may be without PROP_COL
	WEAPON_AREA_MASK = Layers.HITBOX_AREA | Layers.PROP_COL,
	# Layers.ITEM_COL so items (rigid bodies) not fall through each other
	ITEM_COL_MASK = Layers.ENVIRONMENT_COL | Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ITEM_COL,
	# currently checks for weapon or body hit
	PROP_COL_MASK = Layers.WEAPON_AREA | Layers.HITBOX_AREA,

	ALL_CHARACTERS = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL,

	_ZERO_MASK = 0
}
