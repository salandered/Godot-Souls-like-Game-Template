extends Node3D


var LERP_SPEED: float = 8.0


@onready var me: PHCharacter = $".."


var target_y: float

func _ready() -> void:
	target_y = PHEStaticConfig.DEFAULT_Y_OFFSET
	position.y = target_y


func _physics_process(delta: float):
	var current_state := me.get_curr_leaf_state()
	if current_state:
		target_y = current_state.y_offset_adjustment
	else:
		target_y = PHEStaticConfig.DEFAULT_Y_OFFSET
		
	position.y = lerp(position.y, target_y, delta * LERP_SPEED)
