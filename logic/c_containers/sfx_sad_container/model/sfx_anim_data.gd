class_name SFXAnimData
extends RefCountedSystem

## or simply SAD
## should not contain any objects and links.
## just ID/String glue

## sfx type from SFXConstants 
var sad_id: String
## WARNING:
##   Adds SFXConstants.anim_asp_prefix to name. =>
##    - Node names should start with this prefix in the scene
##    - Dont use it while creating SFXAnimData
var anim_sfx_asp_name: String
var signal_id: String


## sad_id_ is the sfx type from SFXConstants
func _init(sad_id_: String, anim_sfx_asp_name_: String, signal_id_: String) -> void:
	self.sad_id = sad_id_
	self.anim_sfx_asp_name = SFXConstants.anim_asp_prefix + anim_sfx_asp_name_
	self.signal_id = signal_id_

	if sad_id_ == "":
		__log_error("sad_id_ is empty", "", "", self)
	if anim_sfx_asp_name_ == "":
		__log_error("anim sfx stream player name is empty", "", "", self)

	if signal_id_ == "":
		__log_error("signal id is empty", "", "", self)


func _to_string() -> String:
	return pp.s("ID", sad_id, "animSfxAsp/sigID", anim_sfx_asp_name, signal_id)


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 2
