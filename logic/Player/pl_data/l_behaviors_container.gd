extends RefCounted
class_name LegBehaviorContainer

class BehaviorData:
	var behavior_name: String
	var supported_actions: SupportedActions


	func _init(behavior_name_: String, supported_: Dictionary) -> void:
		behavior_name = behavior_name_
		supported_actions = SupportedActions.new(supported_)


var node_to_behavior_data: Dictionary = {
	"IdleLegs": BehaviorData.new(Leg.Beh.idle, {
		MotionType.IDLE: Leg.Act.idle,
		MotionType.START: Leg.Act.idle,
		MotionType.LOOP: Leg.Act.idle,
		MotionType.STOP: Leg.Act.idle,
	}),
	"RunLegs": BehaviorData.new(Leg.Beh.run, {
		MotionType.IDLE: Leg.Act.idle,
		MotionType.START: Leg.Act.turn_180,
		MotionType.LOOP: Leg.Act.run,
		MotionType.STOP: Leg.Act.idle,
	}),
	"SprintLegs": BehaviorData.new(Leg.Beh.sprint, {
		MotionType.IDLE: Leg.Act.idle,
		MotionType.START: Leg.Act.idle_to_sprint,
		MotionType.LOOP: Leg.Act.sprint,
		MotionType.STOP: Leg.Act.sprint_to_idle,
	}),
	"DoubleLegs": BehaviorData.new(Leg.Beh.double, {
		MotionType.IDLE: Leg.Act.double,
		MotionType.START: Leg.Act.double,
		MotionType.LOOP: Leg.Act.double,
		MotionType.STOP: Leg.Act.double,
	}),
}


class ActionData:
	var action_name: String
	var anim_id: String
	var motion_type: String

	func _init(
			action_name_: String,
			anim_id_: String,
			motion_type_: String,
		) -> void:
		action_name = action_name_
		anim_id = anim_id_
		motion_type = motion_type_


var node_to_action_data: Dictionary = {
	"Idle": ActionData.new(Leg.Act.idle, A.idle, MotionType.IDLE),
	"IdleToSprint": ActionData.new(Leg.Act.idle_to_sprint, A.idle_to_sprint, MotionType.START),
	# "RunToSprintAction": LegActionData.ActionData.new(Leg.Act.run_to_sprint, A.combat_sprint_start,  MotionType.START),
	"Run": ActionData.new(Leg.Act.run, A.run, MotionType.LOOP),
	"Turn180": ActionData.new(Leg.Act.turn_180, A.turn_180_R, MotionType.START),
	# "IdleTurnToRunL": ActionData.new(Leg.Act.idle_turn_to_run_L, A.idle_turn_to_run_L, MotionType.START),
	"SprintToIdle": ActionData.new(Leg.Act.sprint_to_idle, A.sprint_to_idle, MotionType.STOP),
	"Sprint": ActionData.new(Leg.Act.sprint, A.sprint, MotionType.LOOP),
	"Double": ActionData.new(Leg.Act.double, A.fake_anim, MotionType.IDLE),
}
