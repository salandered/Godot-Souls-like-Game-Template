extends Resource
class_name LegActionData


var action_name: String
var animation_name: String
var motion_type: LegsSM.MotionType

func _init(
		action_name_: String,
		animation_name_: String,
		motion_type_: LegsSM.MotionType,
	) -> void:
	self.action_name = action_name_
	self.animation_name = animation_name_
	self.motion_type = motion_type_
