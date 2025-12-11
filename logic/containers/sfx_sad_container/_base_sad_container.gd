@abstract
class_name BaseSADContainer
extends BaseRefCountedSystem


var sad_id_to_sad: Dictionary[String, SFXAnimData]
var anim_sfx_asp_name_to_sad: Dictionary[String, SFXAnimData]


## DOCS
##  - NOTE: Used ONLY for animation based sfx signals.
##  - container is not really sad, it manages SFXAnimData which stands for 'SAD'
##  - SFXAnimData should be created for any asp_name which could come from AudioTrackKey
##    E.g: for character it will be character SFX types which are animation based
##    Another ex: if character hit is tied to react anim, it will be here. 
## 			If not (emitted on hitbox body entered), no need to define here


func _init():
	var _sad_list: Array[SFXAnimData] = _get_sad_list()
	
	sad_id_to_sad = {}
	anim_sfx_asp_name_to_sad = {}
	for item in _sad_list:
		## warning if sad_id is not unique (should not happen)
		if u.safe_has_no_key(sad_id_to_sad, item.sad_id):
			sad_id_to_sad[item.sad_id] = item

		## warning if anim_sfx_asp_name is not unique (in theory may occur)
		if u.safe_has_no_key(anim_sfx_asp_name_to_sad, item.anim_sfx_asp_name):
			anim_sfx_asp_name_to_sad[item.anim_sfx_asp_name] = item
	

	if len(_sad_list) == 0:
		__log_error("no _sad_list; that is odd", "", "")
	else:
		__log_("_sfx_type_to_sfx_anim_data created")
		for _sfx_anim_data: SFXAnimData in _sad_list:
			__log_("", _sfx_anim_data)
			if not _sfx_anim_data.anim_sfx_asp_name.begins_with(SFXConstants.anim_asp_prefix):
				__log_error("stream player name does not begin with common prefix",
					"",
					"",
					SFXConstants.anim_asp_prefix)


## called on init only
@abstract func _get_sad_list() -> Array[SFXAnimData]


func get_by_sad_id(sad_id: String) -> SFXAnimData:
	var _r: SFXAnimData = u.safe_get_dict_key(sad_id_to_sad, sad_id, null)
	return _r

func get_by_anim_sfx_asp_name(sfx_asp_name: String) -> SFXAnimData:
	## it's ok that anim ASP is not found in specific SAD container
	var _r: SFXAnimData = u.safe_get_dict_key(anim_sfx_asp_name_to_sad, sfx_asp_name, null, WL.SILENT)
	return _r


## __LOGS
# region

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return LogToggler.DEFAULT_REF_C_CONT_INDENT

# endregion
