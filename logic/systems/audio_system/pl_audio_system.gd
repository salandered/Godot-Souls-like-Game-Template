extends CharacterAudioSystem
class_name PrincessAudioSystem


@onready var fs_player_3d: AudioStreamPlayer3D = %FSPlayer3D
@onready var fs_scrape_player_3d: AudioStreamPlayer3D = %FSScrapePlayer3D
@onready var launch_player_3d: AudioStreamPlayer3D = %LaunchPlayer3D
@onready var land_player_3d: AudioStreamPlayer3D = %LandPlayer3D
@onready var whoosh_player_3d: AudioStreamPlayer3D = %WhooshPlayer3D
# @onready var react_on_hit_player_3d: AudioStreamPlayer3D = %ReactOnHitPlayer3D


func get_fs_player_3d() -> AudioStreamPlayer3D:
	return fs_player_3d

func get_fs_scrape_player_3d() -> AudioStreamPlayer3D:
	return fs_scrape_player_3d

func get_launch_player_3d() -> AudioStreamPlayer3D:
	return launch_player_3d

func get_land_player_3d() -> AudioStreamPlayer3D:
	return land_player_3d

func get_whoosh_player_3d() -> AudioStreamPlayer3D:
	return whoosh_player_3d

# func get_react_on_hit_player_3d() -> AudioStreamPlayer3D:
# 	return react_on_hit_player_3d


##

func get_character_run_state_name() -> String:
	return PS.run

func get_character_sprint_state_name() -> String:
	return PS.sprint


## __LOG


func pp_name() -> String:
	return "PrincessAudioSystem"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
