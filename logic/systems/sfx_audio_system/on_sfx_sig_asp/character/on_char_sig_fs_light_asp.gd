class_name OnCharSigFSLightASP
extends OnCharFootStepSigASP


func _change_fs_vol(curr_vol_db: float) -> float:
	return _change_vol_on_light_footstep(curr_vol_db)


## __LOGS
# region

func pp_name() -> String:
	return "OnCharSigFSLightASP"

func __LOG_B() -> bool:
	return false


func __LOG_INDENT() -> int:
	return 6

# endregion
