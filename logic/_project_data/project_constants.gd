class_name Constants
extends RefCounted

static var gravity: float = ProjectSettings.get_setting(PropC.PHYSICS_3D_DEFAULT_GRAVITY)


const BIG_MEANINGLESS_NUMBER: float = 999999.8
const BIG_MEANINGLESS_NUMBER_INT: int = 999998

# todo: consider storing delta in InputPackage. and use it everywhere
# frame dependednt and bad, but for approximate one tick here and there its fine they say
const ONE_FRAME: float = 0.016
const THREE_FRAMES: float = ONE_FRAME * 3

const EPSILON_3: float = 0.001
const EPSILON_5: float = 1e-5
const EPSILON_7: float = 1e-7
const EPSILON_9: float = 1e-9


const BONE_COUNT_53 = 53

## always for any character
const GENERAL_SKELETON := &"GeneralSkeleton"

## always for any skeleton
const ROOT_BONE := &"Root"

const BONE_TRACK_PREFIX: StringName = "%" + Constants.GENERAL_SKELETON + ":"

const ROOT_TRACK_PATH: StringName = BONE_TRACK_PREFIX + Constants.ROOT_BONE


## TODO: used in react on hit. Not accurate values
const PLAYER_MAX_HIT_DAMAGE: float = 15
const ENEMY_MAX_HIT_DAMAGE: float = 35


## recommended to use everywhere, while make changes via ASP3DConfig
const SFX_ASP_BASE_VOL_DB := -1.0
##
const SFX_ASP_BASE_BUS_ID := BusID.GAME_SFX


## DEV

const DEMO_ENEMY_TAG = &"demo_enemy"
