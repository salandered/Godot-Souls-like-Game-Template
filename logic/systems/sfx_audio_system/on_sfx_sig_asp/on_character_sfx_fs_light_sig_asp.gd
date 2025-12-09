class_name OnCharacterSFXFSLightSigASP
extends BaseOnCharacterSFXFootStepSigASP


func _change_vol(curr_vol_db: float) -> float:
	return _change_vol_on_light_footstep(curr_vol_db)


## __LOGS
# region

func pp_name() -> String:
	return "OnCharacterSFXFSLightSigASP"

func __LOG_B() -> bool:
	return false


func __LOG_INDENT() -> int:
	return 6

# endregion
