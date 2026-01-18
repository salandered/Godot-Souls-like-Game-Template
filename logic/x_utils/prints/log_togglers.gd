extends RefCounted
class_name LogToggler

## indents are also stored here
const DEFAULT_INDENT := 0
const DEFAULT_STATIC_INDENT := 8
const DEFAULT_REF_C_CONT_INDENT := 4


## Containers
const SAD_C_B := false
const SIG_C_B := false

# COMMON
const DEV_B := true_b
const COLLISION_B := false


const REACT_UTILS_B := false

# CONTAINER
const PL_STATES_CONTAINER_B := false
const ANIM_CONTAINER_B := false
const E_CONTAINER_B := false

# FIGHT
const FIGHT_B := false
const COMBO_B := false
const HIT_HURT_BOX_B := false
const WEAPON_B := false

# PLAYER PSM
const PSM_B := false
const BEHAVIOR_INTERNAL_FILTER := false
const ACTION_ANIM_B := false
const META_STATES_B := false

# PLAYER LSM
const LSM_BEH_B := false
const LSM_ACTION_B := false

# PL SYSTEMS
const SKM_B := false
const input_gathering_B := false
const FANCY_CAM_B := false
const AWARENESS_B := false

# ENEMY
const PHE_INTERNAL_FILTER_B := true_b
const PHE_CHECK_B := true_b
const PHE_B := true_b
const PHE_ANIM_B := true_b
const E_ANIM_MANAGER_B := true_b


class FEEL:
	const ENEMY := false
	const ENEMY_UI := false
	const PL := false
	const PL_UI := false
	const BAR := false


class ITEM:
	const BASE_PICK := false

class SFX:
	const META_ASP := false


class UI:
	const M_OPTION_CONTROL := false
	const MAIN_MENU := false


##

const FEEL_INDENT := 10

## -- system ##

## for bright colors (using extenstion)
const true_b := true
