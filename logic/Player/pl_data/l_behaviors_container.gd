extends RefCounted
class_name LegBehaviorContainer

class _BehaviorData:
	var behavior_name: String
	var supported_actions: SupportedActions

	func _init(behavior_name_: String, supported_: SupportedActions) -> void:
		self.behavior_name = behavior_name_
		self.supported_actions = supported_


class _ActionData:
	var action_name: String
	var anim_id: String
	var motion_type: String

	func _init(
			action_name_: String,
			anim_id_: String,
			motion_type_: String,
		) -> void:
		self.action_name = action_name_
		self.anim_id = anim_id_
		self.motion_type = motion_type_


var node_to_l_behavior_data: Dictionary = {
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
				# Leg.Act.vert_locked_run,
			]
	)),
	# "DodgeLegs": _BehaviorData.new(Leg.Beh.dodge,
	# 	SupportedActions.new({
	# 		MotionType.IDLE: Leg.Act.idle,
	# 		MotionType.START: Leg.Act.dodge,
	# 		MotionType.LOOP: Leg.Act.dodge,
	# 		MotionType.STOP: Leg.Act.idle,
	# 		},
	# 		[]
	# )),
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


var node_to_l_action_data: Dictionary = {
	"IdleToSprint": _ActionData.new(Leg.Act.idle_to_sprint, A.move.idle_to_sprint, MotionType.START),

	"Idle": _ActionData.new(Leg.Act.idle, A.move.idle, MotionType.IDLE),
	"Run": _ActionData.new(Leg.Act.run, A.move.run, MotionType.LOOP),
	"Turn180": _ActionData.new(Leg.Act.turn_180, A.move.turn_180_R, MotionType.START),

	"Strafe": _ActionData.new(Leg.Act.strafe, A.strafe.strafe_R, MotionType.LOOP),
	# "VertLockedWalk": _ActionData.new(Leg.Act.vert_locked_walk, A.combat_walk_f, MotionType.LOOP),
	# "VertLockedRun": _ActionData.new(Leg.Act.vert_locked_run, A.strafe.combat_run_f, MotionType.LOOP),
	# "Dodge": _ActionData.new(Leg.Act.dodge, A.dodge.dodge_R, MotionType.IDLE),

	"FastTurn180": _ActionData.new(Leg.Act.fast_turn_180, A.move.fast_turn_180_R, MotionType.START),
	"SprintToIdle": _ActionData.new(Leg.Act.sprint_to_idle, A.move.sprint_to_idle, MotionType.STOP),
	"Sprint": _ActionData.new(Leg.Act.sprint, A.move.sprint, MotionType.LOOP),
	"_Double": _ActionData.new(Leg.Act.double, A.air.midair, MotionType.IDLE),
	# "RunToSprintAction": LegActionData._ActionData.new(Leg.Act.run_to_sprint, A.combat_sprint_start,  MotionType.START),
	# "Turn90ToRun": _ActionData.new(Leg.Act.turn_90_to_run, A.turn_90_to_run_R, MotionType.START),
}
