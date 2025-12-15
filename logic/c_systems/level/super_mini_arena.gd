extends BaseLevel

@onready var base_asp: AudioStreamPlayer = %base_asp
@onready var vibe_asp: AudioStreamPlayer = %vibe_asp
@onready var ph_enemy: PHCharacter = $PHEnemy
@onready var ph_enemy_2: PHCharacter = $PHEnemy2
@onready var ph_enemy_3: PHCharacter = $PHEnemy3

var enemies: Array[PHCharacter]

const AIR_WAVE_2 = preload("uid://cxfgvp3futm7q")


func _ready():
	base_asp.play()
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
	


func _on_ph_enemy_sig_land_wave(char_glob_position: Vector3, anim: String) -> void:
	spawn_shockwave(char_glob_position, anim)


func _on_princess_sig_land_wave(char_glob_position: Vector3, anim: String) -> void:
	spawn_shockwave(char_glob_position, anim)
	
	
func spawn_shockwave(char_glob_position: Vector3, anim: String):
	if AIR_WAVE_2:
		var effect :AirWave2= AIR_WAVE_2.instantiate()
		effect.animation_name = anim
		get_parent().add_child(effect)
		
		effect.global_position = char_glob_position
		effect.global_position.y -= 0.2
