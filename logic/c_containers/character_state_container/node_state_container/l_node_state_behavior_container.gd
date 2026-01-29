extends RefCounted
class_name LegBehaviorContainer


class _BehaviorData:
	var behavior_name: String
	var supported_actions: SupportedActions

	func _init(behavior_name_: String, supported_: SupportedActions) -> void:
		self.behavior_name = behavior_name_
		self.supported_actions = supported_


class _LActionData extends StatesContainer._BaseActionData:
	pass


var node_to_l_behavior_data: Dictionary[String, _BehaviorData] = {
	"IdleLegs": _BehaviorData.new(Leg.Beh.idle,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.idle,
			MotionType.LOOP: Leg.Act.idle,
			MotionType.STOP: Leg.Act.idle,
			},
			[]
	)),
	"RunLegs": _BehaviorData.new(Leg.Beh.run,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.run,
			MotionType.LOOP: Leg.Act.run,
			MotionType.STOP: Leg.Act.idle,
			},
			[
				Leg.Act.turn_180,
			]
	)),
	"StrafeLegs": _BehaviorData.new(Leg.Beh.strafe,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.strafe,
			MotionType.LOOP: Leg.Act.strafe,
			MotionType.STOP: Leg.Act.idle,
			},
			[
				Leg.Act.turn_180,
			]
	)),
	"SprintLegs": _BehaviorData.new(Leg.Beh.sprint,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.idle_to_sprint,
			MotionType.LOOP: Leg.Act.sprint,
			MotionType.STOP: Leg.Act.sprint_to_idle,
			},
			[Leg.Act.fast_turn_180]
	)),
	"_DoubleLegs": _BehaviorData.new(Leg.Beh.double,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.double,
			MotionType.START: Leg.Act.double,
			MotionType.LOOP: Leg.Act.double,
			MotionType.STOP: Leg.Act.double,
			},
			[]
	)),
}


var node_to_l_action_data: Dictionary[String, _LActionData] = {
	"IdleToSprint": _LActionData.new(Leg.Act.idle_to_sprint, A.loco.idle_to_sprint, MotionType.START),

	"Idle": _LActionData.new(Leg.Act.idle, A.loco.idle, MotionType.IDLE),
	"Run": _LActionData.new(Leg.Act.run, A.loco.run, MotionType.LOOP),
	"Turn180": _LActionData.new(Leg.Act.turn_180, A.loco.turn_180_R, MotionType.START),

	"Strafe": _LActionData.new(Leg.Act.strafe, A.strafe.strafe_R, MotionType.LOOP),

	"FastTurn180": _LActionData.new(Leg.Act.fast_turn_180, A.loco.fast_turn_180_R, MotionType.START),
	"SprintToIdle": _LActionData.new(Leg.Act.sprint_to_idle, A.loco.sprint_to_idle, MotionType.STOP),
	"Sprint": _LActionData.new(Leg.Act.sprint, A.loco.sprint, MotionType.LOOP),
	"_Double": _LActionData.new(Leg.Act.double, A.air.midair, MotionType.IDLE),
}
