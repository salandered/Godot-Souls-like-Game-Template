extends LegsBehavior


func _ready() -> void:
	var supported = {
		MotionType.IDLE: Leg.Act.idle,
		MotionType.START: Leg.Act.idle,
		MotionType.LOOP: Leg.Act.idle,
		MotionType.STOP: Leg.Act.idle,
	}
	
	supported_actions = SupportedActions.new(supported)
