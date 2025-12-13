extends RefCounted
class_name BusID


## master
const MASTER_ := "Master"

## menu/ui
const MENU_MUSIC := "menu_Music"
const UI_SFX := "UI_SFX"

## game
const GAME_MUSIC := "game_Music"
const GAME_SFX := "game_SFX"


## dev
const TEST_SFX := "test_SFX"
const AA_MUTED := "AA_muted"


# todo: try later
# static func get_all() -> Array:
# 	var script: Script = load("res://project/audio_buses/bus_ids.gd") as Script
# 	# Or, if cyclic reference isn't an issue 
# 	# var script = BusID 
	
# 	if script:
# 		return script.get_script_constant_map().values()
# 	return []