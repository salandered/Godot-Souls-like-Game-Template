extends LegsBehavior

func _ready() -> void:
	var supported = {
		MotionType.IDLE: Leg.Act.double,
		MotionType.START: Leg.Act.double,
		MotionType.LOOP: Leg.Act.double,
		MotionType.STOP: Leg.Act.double,
	}
	
	supported_actions = SupportedActions.new(supported)
