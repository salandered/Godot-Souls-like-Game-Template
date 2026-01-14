class_name Constants
extends RefCounted

const BIG_MEANINGLESS_NUMBER: float = 99999

# todo: store delta in InputPackage. and use it everywhere
const ONE_FRAME: float = 0.016 # just for one tick its fine they say
const THREE_FRAMES: float = ONE_FRAME * 3

const EPSILON_3: float = 0.001
const EPSILON_5: float = 1e-5
const EPSILON_7: float = 1e-7
const EPSILON_9: float = 1e-9


const BONE_COUNT = 53

## always for any character
const GENERAL_SKELETON: String = "GeneralSkeleton"

## always for any skeleton
const ROOT_BONE: String = "Root"

const BONE_TRACK_PREFIX: String = "%" + Constants.GENERAL_SKELETON + ":"

const ROOT_TRACK_PATH: String = BONE_TRACK_PREFIX + Constants.ROOT_BONE


const PLAYER_MAX_HIT_DAMAGE: float = 15
const ENEMY_MAX_HIT_DAMAGE: float = 35


## recommended to use everywhere, while make changes via ASP3DConfig
const SFX_ASP_BASE_VOL_DB := -1.0
const SFX_ASP_MAX_VOL_DB := 3.0
##
const SFX_ASP_BASE_BUS_ID := BusID.GAME_SFX


## Properties for tweens

class Prop:
	const ASP_VOLUME_DB = "volume_db"
	const CONTROL_MODULATE_A = "modulate:a"