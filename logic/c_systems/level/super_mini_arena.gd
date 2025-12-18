extends BaseLevel

@onready var base_asp: AudioStreamPlayer = %base_asp
@onready var vibe_asp: AudioStreamPlayer = %vibe_asp
@onready var ph_enemy: PHCharacter = $PHEnemy
@onready var ph_enemy_2: PHCharacter = $PHEnemy2
@onready var ph_enemy_3: PHCharacter = $PHEnemy3

var enemies: Array[PHCharacter]


func _ready():
	base_asp.bus = BusID._TRACK_BASE
	vibe_asp.bus = BusID._TRACK_VIBE
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
