@tool
@icon("res://-assets-/x_icons/level/icon_level_yellow.png")

class_name MiniArena
extends BaseLevel

@onready var base_asp: AudioStreamPlayer = %base_asp
@onready var vibe_asp: AudioStreamPlayer = %vibe_asp
@onready var ph_enemy: PHCharacter = $PHEnemy
@onready var ph_enemy_2: PHCharacter = $PHEnemy2
@onready var ph_enemy_3: PHCharacter = $PHEnemy3

var enemies: Array[PHCharacter]


func __soft_dependencies() -> Array[Object]:
	return [
		base_asp,
		vibe_asp,
		ph_enemy,
		ph_enemy_2,
		ph_enemy_3
	]


func basic_tonemap_exposure() -> float:
	return 1.1

func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.0


func initialise():
	if base_asp:
		base_asp.bus = BusID._TRACK_BASE
		base_asp.play()
	if vibe_asp:
		vibe_asp.bus = BusID._TRACK_VIBE

	__perform_validation()
	enemies = [ph_enemy, ph_enemy_2, ph_enemy_3]


func _on_ph_enemy_sig_angry_raised() -> void:
	vibe_asp.play()


func _on_ph_enemy_sig_death_raised() -> void:
	var all_quiet: bool = true
	for e in enemies:
		if e.angry_raised:
			all_quiet = false
	if all_quiet:
		vibe_asp.stop()


func __LOG_B() -> bool:
	return false
