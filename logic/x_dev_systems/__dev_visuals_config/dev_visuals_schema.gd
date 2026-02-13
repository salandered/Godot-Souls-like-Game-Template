class_name DVS # dev visuals schema
extends RefCounted


enum DVSection {
	UNKNOWN = 0,
	## specific
	B_OVERLAY_PANEL = 1,
	## primitive changer
	B_CHANGER = 10,
	S_CHANGER,
	F_CHANGER,
	## 
	COLOR_CHANGER = 20,
	## composite
	B_CHAR_DV = 30,
}

enum KeyBOverlayPanel {
	UNKNOWN = 0,
	## System Info
	PROFILER = 1,
	## Logs
	ALL_LOG = 10,
	ERROR_LOG,
	SIG_LOG,
	## Input Logs
	RAW_INPUT = 20,
	ACTION_INPUT,
	PLAYER_INPUT_INFO,
	## Audio
	BUS_SPECTRUM = 30,
	## Specific
	CAM_NODES = 50,
	SUBVIEWPORT,
	PLAYER_SK_ANIMATOR,
	ENEMY_ANIMATOR,
	PLAYER_COMBO,
	ENEMY_MOVEMENT_INFO,
	## User
	TUT = 100,
}

enum KeyBValueChanger {
	UNKNOWN = 0,
	## weapon hit
	WEAPON_HIT = 20,
	WEAPON_HIT_EVERY_FRAME,
	WEAPON_HIT_SHADED,
	WEAPON_HIT_SNAPPED_HITS,
	## mesh visuals
	SHOW_BONES_SIMPLIFIED = 41,
	WEAR_HAT,
	DOWNCAST,
}

enum KeySValueChanger {
	UNKNOWN = 0,
	## log regex
	ALL_LOG_FILTER = 10,
	ERROR_LOG_FILTER,
	SIG_FILTER,
	## audio
	DV_SPECTRUM_AUDIO_BUS = 20
}

enum KeyFValueChanger {
	UNKNOWN = 0,
	## debug duration
	GHOST_DUR_SEC = 10,
	WEAPON_HIT_DUR,
	## UI 
	GRID_V_SEP = 30,
}

enum KeyColorChanger {
	UNKNOWN = 0,
	## char visuals
	HAIR_COLOR = 1
}

const DEF_OFF_COLOR := Color.TRANSPARENT

## Returns -1 in case of error
static func key_char_dv(ct: CharacterType, dvt: CharDVType) -> int:
	var _r := BitKeyUtils.combine(ct, dvt)
	if _r.err: return -1
	return _r.value

## Returns Vector(-1, -1) in case of error
static func get_enums_from_key_char_dv(key_char_dv_: int) -> Vector2i:
	var _r := BitKeyUtils.split(key_char_dv_)
	if _r.err: return Vector2i(-1, -1)
	return _r.value


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
	WEAPON_HITBOX, # 5
	SKELETON_VISUALS, # 6
	HIDE_MESH_VISUALS, # 7
	}
