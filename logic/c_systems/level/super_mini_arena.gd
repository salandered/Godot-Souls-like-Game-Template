@tool
@icon("res://-assets-/x_icons/level/icon_level_yellow.png")

class_name MiniArena
extends BaseLevel


func basic_tonemap_exposure() -> float:
	return 1.1

func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.0


func initialise():
	pass


func __LOG_B() -> bool:
	return false
