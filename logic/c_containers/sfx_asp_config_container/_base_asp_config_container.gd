@abstract
class_name BaseSFXASPConfigContainer
extends RefCountedSystem


var _sfx_asp_configs: Dictionary[String, ASP3DConfig] = {}


func _init():
	_sfx_asp_configs = _get_dict_data()
	
	if not error_.empty_list(_sfx_asp_configs.values(), "_sfx_asp_configs"):
		__log_("Container data created")


## nullable
func get_by_sfx_type_id(sfx_type_id: String) -> ASP3DConfig:
	var _r: ASP3DConfig = u.safe_get_dict_key(_sfx_asp_configs, sfx_type_id, null, WL.SILENT)
	return _r


## DATA BUILDER

## while there is a little amount of SFX types, we add them all
## implementation can skip unneeded ones, 
## there will be deleted from the result dict with which container is initialised
## and if for example weapon accidently left footstep entry, its won't affect anything as long as other systems dont wanna walking sword ...
func _get_dict_data() -> Dictionary[String, ASP3DConfig]:
	var dict_: Dictionary[String, ASP3DConfig] = {
		## fs like
		SFXConstants.ID_.footstep: _get_footstep_config(),
		SFXConstants.ID_.footstep_light: _get_footstep_light_config(),
		SFXConstants.ID_.footstep_scrape: _get_footstep_scrape_config(),
		SFXConstants.ID_.move_noise: _get_move_noise_config(),
		SFXConstants.ID_.jingles: _get_jingle_config(),
		
		##
		SFXConstants.ID_.launch: _get_launch_config(),
		SFXConstants.ID_.land: _get_land_config(),
		SFXConstants.ID_.whoosh_char: _get_whoosh_config(),
		SFXConstants.ID_.react_on_hit: _get_react_on_hit_config(),

		## weapon
		SFXConstants.ID_.whoosh_weapon: _get_whoosh_weapon_config(),
		SFXConstants.ID_.hit_weapon: _get_hit_weapon_config(),
		SFXConstants.ID_.hit_target: _get_hit_target_config(),

		##
		SFXConstants.ID_.unique: _get_unique_config(),

	}

	for key: String in dict_.keys():
		var item: ASP3DConfig = dict_[key]
		if item == null:
			dict_.erase(key)
			__log_("item == null for key", key, "erased from SFXASPConfigContainer")
	return dict_


## Override this values in implementation

## fs like 
@abstract func _get_footstep_config() -> ASP3DConfig

@abstract func _get_footstep_light_config() -> ASP3DConfig

@abstract func _get_footstep_scrape_config() -> ASP3DConfig

@abstract func _get_move_noise_config() -> ASP3DConfig

@abstract func _get_jingle_config() -> ASP3DConfig
##
@abstract func _get_launch_config() -> ASP3DConfig

@abstract func _get_land_config() -> ASP3DConfig

@abstract func _get_whoosh_config() -> ASP3DConfig


@abstract func _get_react_on_hit_config() -> ASP3DConfig


## weapon
@abstract func _get_whoosh_weapon_config() -> ASP3DConfig

@abstract func _get_hit_weapon_config() -> ASP3DConfig

@abstract func _get_hit_target_config() -> ASP3DConfig

##
@abstract func _get_unique_config() -> ASP3DConfig


## __LOGS
# region

func pp_name() -> String:
	return u.construct_obj_pp_name(self)

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_REF_C_CONT_INDENT

# endregion

const BG_MOVE_NOISE = preload("uid://cga1kwd4shtmo")
const JINGLES = preload("uid://c130xlrvi8scs")

const HEAVY_WHOOSH = preload("uid://dnqvc318bissn")

const WEAPON_WHOOSH: AudioStream = preload("uid://qufmydm4eeq4")
const METAL_SWORD_HIT: AudioStream = preload("uid://g4dtkcleinh8")

## concrete impact
const HIT_BONE_ROCK_FALL_CAT: AudioStream = preload("uid://bi76gdwpvrkw7")

const HIT_SWORD = preload("uid://dbswu1dm262sj")
const BIG_CRASH_ROCK = preload("uid://cre4k58suo6da")

const AURA_PICKING_3 = preload("uid://wwwrajhmr0qm")

const BASE_WOOD_SWORD_COMBAT_06_HIT = preload("uid://c8yroptc2jw18")

## char impact
const BOW_IMPACT = preload("uid://bsaxp48f20puq")
const BONE_CRUNCH = preload("uid://ct8xhr3e4gglp")
const SK_IMPACTS = preload("uid://c37c50ip2o8ol")
##
const TORCH_ATTACK = preload("uid://cgc4yvwa21hc4")
