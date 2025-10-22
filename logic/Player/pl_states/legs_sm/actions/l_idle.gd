extends LegsAction


func _ready():
	blend_time_by_action = {
		Leg.Act.sprint_to_idle: 0.3,
		Leg.Act.turn_180: 0.3
	}


func update(input_: InputPackage, _delta: float) -> void:
	get_player().velocity = Vector3.ZERO
