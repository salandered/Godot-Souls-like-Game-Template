extends BaseNodeCharacterSystem
class_name CharacterAudioSystem

@onready var footsteps_stream_player: AudioStreamPlayer3D = %FootstepsStreamPlayer

signal SIG_SFX_footstep()


func _ready():
	assert(footsteps_stream_player)
	

func is_player() -> bool:
	return true


func pp_name() -> String:
	return "test audio system"

func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
