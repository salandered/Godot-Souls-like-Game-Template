extends CharacterBody3D
class_name Gundyr

@export var player: Princess
@onready var state_machine = $GundyrHFSM as BaseHFSMState


func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL

	
	state_machine.player = player
	state_machine._on_enter()
	state_machine._accept_export_fields()


func _physics_process(delta):
	state_machine._update(delta)
