extends RefCounted
class_name Collision

## DANGER: Don't change without checking project settings!
enum Layers {
	ENVIRONMENT_COL = 1 << 0, # bit 0
	PLAYER_COL = 1 << 1, # bit 1
	OTHER_CHAR_COL = 1 << 2, # bit 2 (enemies + NPCs)
	HITBOX_AREA = 1 << 3, # bit 3 (vulnerable area)
	WEAPON_AREA = 1 << 4, # bit 4 (damage-dealing)
	ITEM_COL = 1 << 5, # bit 5
}

enum Masks {
	ENVIRONMENT_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ITEM_COL,
	PLAYER_COL_MASK = Layers.OTHER_CHAR_COL | Layers.ENVIRONMENT_COL, # | Layers.ITEM_COL,
	OTHER_CHAR_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ENVIRONMENT_COL, # | Layers.ITEM_COL,
	HITBOX_AREA_MASK = Layers.WEAPON_AREA,
	WEAPON_AREA_MASK = Layers.HITBOX_AREA,
	ITEM_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ENVIRONMENT_COL | Layers.ITEM_COL,
	_DEV_ZERO_MASK = 0
}


## TROUBLESHOOTING
# ISSUE your character sometimes inexplicably speeding up when pushing a RigidBody? 
# The cause of this problem is that the CharacterBody node has logic to ensure the character stays 
# stationary on moving platforms, and sometimes when you collide into the rigidbody object it ends up 
# being counted as a moving platform. 
# So the CharacterBody inherits the velocity of the rigidbody, because it thinks the rigidbody is 
# a platform it has to stick to. 
# SOLUTION you simply have to go into the "Moving Platform" part of the CharacterBody's node settings, 
# and disable the physics layer you're using for the rigidbody objects. 
# By default all physics layers are enabled for being affected by the moving platform logic. 
# Since we don't want objects in this layer to be counted as moving platforms, we just disable that layer.
