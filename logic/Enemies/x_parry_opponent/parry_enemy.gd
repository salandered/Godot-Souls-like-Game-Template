extends CharacterBody3D


@onready var ai = $AI
@onready var model = $Model as PlayerModel
@onready var visuals = $Visuals as PlayerVisuals


func _ready() -> void:
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK
	
	visuals.accept_model(model)


func _physics_process(delta):
	var input = ai.create_input(delta)
	model.update(input, delta)
	input.queue_free()
