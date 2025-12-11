@abstract
class_name BaseSFXASPConfigContainer
extends BaseRefCountedSystem


var _sfx_asp_configs: Dictionary[String, ASPConfig] = {}


func _init():
	_sfx_asp_configs = _get_dict_data()
	
	if not error_.empty_list(_sfx_asp_configs.values(), "_sfx_asp_configs"):
		__log_("Container data created")


func get_by_sfx_type_id(sfx_type_id: String) -> ASPConfig:
	var _r: ASPConfig = u.safe_get_dict_key(_sfx_asp_configs, sfx_type_id, null, WL.SILENT)
	return _r


## DATA BUILDER

## while there is a little amount of SFX types, we add them all
## implementation can skip unneeded ones, 
## there will be deleted from the result dict with which container is initialised
## and if for example weapon accidently left footstep entry, its won't affect anything as long as other systems dont wanna walking sword ...
func _get_dict_data() -> Dictionary[String, ASPConfig]:
	var dict_: Dictionary[String, ASPConfig] = {
		## fs
		SFXConstants.ID_.footstep: _get_footstep_config(),
		SFXConstants.ID_.footstep_light: _get_footstep_light_config(),
		SFXConstants.ID_.footstep_scrape: _get_footstep_scrape_config(),
		
		##
		SFXConstants.ID_.launch: _get_launch_config(),
		SFXConstants.ID_.land: _get_land_config(),
		SFXConstants.ID_.whoosh: _get_whoosh_config(),
		SFXConstants.ID_.move_noise: _get_move_noise_config(),

		## weapon
		SFXConstants.ID_.whoosh_weapon: _get_whoosh_weapon_config(),
		SFXConstants.ID_.hit_weapon: _get_hit_weapon_config(),
		SFXConstants.ID_.hit_target: _get_hit_target_config(),
	}

	for key: String in dict_.keys():
		var item: ASPConfig = dict_[key]
		if item == null:
			dict_.erase(key)
			__log_("item == null for key", key, "erased from SFXASPConfigContainer")
	return dict_


## Override this values in implementation

## fs
@abstract func _get_footstep_config() -> ASPConfig

@abstract func _get_footstep_light_config() -> ASPConfig

@abstract func _get_footstep_scrape_config() -> ASPConfig

##
@abstract func _get_launch_config() -> ASPConfig

@abstract func _get_land_config() -> ASPConfig

@abstract func _get_whoosh_config() -> ASPConfig

@abstract func _get_move_noise_config() -> ASPConfig


## weapon
@abstract func _get_whoosh_weapon_config() -> ASPConfig

@abstract func _get_hit_weapon_config() -> ASPConfig

@abstract func _get_hit_target_config() -> ASPConfig


## __LOGS
# region

func pp_name() -> String:
	return u.construct_obj_pp_name(self)

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_REF_C_CONT_INDENT

# endregion
