extends RefCounted
class_name LegBehaviorContainer

class BehaviorData:
	var behavior_name: String
	var supported_actions: SupportedActions

	func _init(behavior_name_: String, supported_: SupportedActions) -> void:
		behavior_name = behavior_name_
		supported_actions = supported_


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


var node_to_l_behavior_data: Dictionary = {
	"IdleLegs": BehaviorData.new(Leg.Beh.idle,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.idle,
			MotionType.LOOP: Leg.Act.idle,
			MotionType.STOP: Leg.Act.idle,
			},
			[]
	)),
	"RunLegs": BehaviorData.new(Leg.Beh.run,
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
	"StrafeLegs": BehaviorData.new(Leg.Beh.strafe,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.strafe,
			MotionType.LOOP: Leg.Act.strafe,
			MotionType.STOP: Leg.Act.idle,
			},
			[
				Leg.Act.combat_walk,
			]
	)),
	"SprintLegs": BehaviorData.new(Leg.Beh.sprint,
		SupportedActions.new({
			MotionType.IDLE: Leg.Act.idle,
			MotionType.START: Leg.Act.idle_to_sprint,
			MotionType.LOOP: Leg.Act.sprint,
			MotionType.STOP: Leg.Act.sprint_to_idle,
			},
			[Leg.Act.fast_turn_180]
	)),
	"DoubleLegs": BehaviorData.new(Leg.Beh.double,
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
	"IdleToSprint": ActionData.new(Leg.Act.idle_to_sprint, A.idle_to_sprint, MotionType.START),
	
	"Idle": ActionData.new(Leg.Act.idle, A.idle, MotionType.IDLE),
	"Run": ActionData.new(Leg.Act.run, A.run, MotionType.LOOP),
	"Turn180": ActionData.new(Leg.Act.turn_180, A.turn_180_R, MotionType.START),

	"Strafe": ActionData.new(Leg.Act.strafe, A.strafe_R, MotionType.LOOP),
	"CombatWalk": ActionData.new(Leg.Act.combat_walk, A.combat_walk, MotionType.LOOP),

	"FastTurn180": ActionData.new(Leg.Act.fast_turn_180, A.fast_turn_180_R, MotionType.START),
	"SprintToIdle": ActionData.new(Leg.Act.sprint_to_idle, A.sprint_to_idle, MotionType.STOP),
	"Sprint": ActionData.new(Leg.Act.sprint, A.sprint, MotionType.LOOP),
	"Double": ActionData.new(Leg.Act.double, A.fake_anim, MotionType.IDLE),
	# "RunToSprintAction": LegActionData.ActionData.new(Leg.Act.run_to_sprint, A.combat_sprint_start,  MotionType.START),
	# "Turn90ToRun": ActionData.new(Leg.Act.turn_90_to_run, A.turn_90_to_run_R, MotionType.START),
}
