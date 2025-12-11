extends CharacterSFXSystem
class_name PrincessSFXSystem


@onready var fs_player_3d: AudioStreamPlayer3D = %FSASP3D
@onready var fs_scrape_player_3d: AudioStreamPlayer3D = %FSScrapeASP3D
@onready var launch_player_3d: AudioStreamPlayer3D = %LaunchASP3D
@onready var land_player_3d: AudioStreamPlayer3D = %LandASP3D
@onready var whoosh_player_3d: AudioStreamPlayer3D = %WhooshASP3D
# @onready var react_on_hit_player_3d: AudioStreamPlayer3D = %ReactOnHitPlayer3D


func get_fs_asp_3d() -> AudioStreamPlayer3D:
	return fs_player_3d

func get_fs_scrape_asp_3d() -> AudioStreamPlayer3D:
	return fs_scrape_player_3d

func get_launch_asp_3d() -> AudioStreamPlayer3D:
	return launch_player_3d

func get_land_asp_3d() -> AudioStreamPlayer3D:
	return land_player_3d

func get_whoosh_asp_3d() -> AudioStreamPlayer3D:
	return whoosh_player_3d

# func get_react_on_hit_asp_3d() -> AudioStreamPlayer3D:
# 	return react_on_hit_player_3d


## __LOG



func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
