extends RefCounted
class_name Constants

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