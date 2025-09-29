extends Resource
class_name LegActionData

var action_name: String
var animation_name: String
# TODO: blend_time to AnimationData
var blend_time: float
var motion_type: String

func _init(
		action_name_: String,
		animation_name_: String,
		blend_time_: float = 0.2,
		motion_type_: String = MotionType.IDLE,
	) -> void:
	self.action_name = action_name_
	self.animation_name = animation_name_
	self.blend_time = blend_time_
	self.motion_type = motion_type_
