@tool
@icon("res://-assets-/x_icons/level/icon_level_blue_alt.png")

class_name DemoLevel
extends BaseLevel

var fight_song_triggered: bool = false

const WAVE_PAINT_3 = preload("uid://dpmsb2v7xcwau")

func basic_tonemap_exposure() -> float:
	return 1.6

func tonemap_exposure_no_vol_fog_compensation() -> float:
	return 0.1


func initialise() -> void:
	for item in get_descendants.rigid_bodies(self):
		# print_.prefix_s("~~~~~~~~~", item, item.name)
		item.collision_layer = Collision.Layers.ITEM_COL
		item.collision_mask = Collision.Masks.ITEM_COL_MASK
		# print_.collisions(item)


	for item in get_descendants.static_bodies(self):
		# if item is BreakableStatic:
			# item.collision_layer = Collision.Layers.ENVIRONMENT_COL | Collision.Layers.PROP_COL
		# else:
		item.collision_layer = Collision.Layers.ENVIRONMENT_COL


func _on_play_secret_e_fight_sig_player_entered(incoming_body: Node3D) -> void:
	if WAVE_PAINT_3 and WAVE_PAINT_3 is AudioStream:
		if not fight_song_triggered:
			_bg_music_system.play_priority_track(WAVE_PAINT_3, -8.0, 22.0, 5.0)
			fight_song_triggered = true
