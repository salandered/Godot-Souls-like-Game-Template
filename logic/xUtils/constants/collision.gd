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

enum Mask {
	ENVIRONMENT_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ITEM_COL,
	PLAYER_COL_MASK = Layers.OTHER_CHAR_COL | Layers.ITEM_COL | Layers.ENVIRONMENT_COL,
	OTHER_CHAR_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ITEM_COL | Layers.ENVIRONMENT_COL,
	HITBOX_AREA_MASK = Layers.WEAPON_AREA,
	WEAPON_AREA_MASK = Layers.HITBOX_AREA,
	ITEM_COL_MASK = Layers.PLAYER_COL | Layers.OTHER_CHAR_COL | Layers.ENVIRONMENT_COL
}

# # Inspector-friendly exports
# @export(int, FLAGS, "Player", "OtherChar", "Weapon", "Hitbox", "Item", "Env")
# var collision_layer := Layers.PLAYER_COL

# @export(int, FLAGS, "Player", "OtherChar", "Weapon", "Hitbox", "Item", "Env")
# var collision_mask := player_col_mask
