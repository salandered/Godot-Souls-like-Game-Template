class_name DVS # dev visuals schema
extends RefCounted


enum DVSection {
	UNKNOWN, # 0
	OVERLAY_PANEL, # 1
	VALUE_CHANGER, # 2
	CHAR_DV, # 3
}

enum KeyOverlayPanel {
	UNKNOWN, # 0
	TUT, # 1
	PROFILER, # 2
	CAM_NODES, # 3
	ALL_LOG, # 4
	SIG_DEBUG, # 5
	ERROR_LOG, # 6
	SUBVIEWPORT, # 7
}

enum KeyValueChanger {
	UNKNOWN, # 0
	GHOST_DUR_SEC, # 1
	GRID_V_SEP, # 2
	SIG_FILTER, # 3
	ALL_LOG_FILTER, # 4
	ERROR_LOG_FILTER, # 5
	WEAPON_HIT, # 6
	WEAPON_HIT_EVERY_FRAME # 7
	}

## Returns RO.IntReturn
static func key_char_dv(ct: CharacterType, dvt: CharDVType) -> RO.IntReturn:
	return BitKeyUtils.combine(ct, dvt)


static func get_enums_from_key_char_dv(key_char_dv_: int) -> RO.Vector2iReturn:
	return BitKeyUtils.split(key_char_dv_)


enum CharacterType {
	UNKNOWN, # 0
	PLAYER, # 1
	HSM_ENEMY, # 2
	SIMPLE_ENEMY # 3
	}

enum CharDVType {
	UNKNOWN, # 0
	STATE_INFO, # 1
	ATTACK_INFO, # 2
	WEAPON_TRAIL, # 3
	HITBOX, # 4
	WEAPON_HITBOX # 5
	}
