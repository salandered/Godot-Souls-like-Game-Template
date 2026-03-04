@tool
@icon("res://-assets-/x_icons/level/icon_level_blue_alt.png")

class_name DemoLevel
extends BaseLevel

var fight_song_triggered: bool = false


const WAVE_PAINT_3 = preload("uid://dpmsb2v7xcwau")
const BACK_MELODY = preload("uid://b3mvk1hw0imcv")


func basic_tonemap_exposure() -> float:
	return 1.6

func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.1


func initialize() -> void:
	for item: RigidBody3D in get_descendants.rigid_bodies(self ):
		item.collision_layer = Collision.Layers.ITEM_COL
		item.collision_mask = Collision.Masks.ITEM_COL_MASK
		# print_debug.collisions(item)


	for item in get_descendants.static_bodies(self ):
		item.collision_layer = Collision.Layers.ENVIRONMENT_COL


func _on_play_secret_e_fight_sig_player_entered(incoming_body: Node3D) -> void:
	if WAVE_PAINT_3 and WAVE_PAINT_3 is AudioStream:
		if not fight_song_triggered:
			_bg_music_system.play_priority_track(WAVE_PAINT_3, -12.0, 22.0, 5.0)
			fight_song_triggered = true


func _on_secret_enemy_sig_death_raised() -> void:
	_bg_music_system.play_priority_track(BACK_MELODY, -12.0, 60, 15.0)
