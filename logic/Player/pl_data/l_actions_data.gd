extends Resource
class_name LegActionData

var action_name: String
var animation_name: String
# TODO: duplication with PlayerAction with backend_animation_name and blend_time
#       * may be additional structure for animation
#       * may be there is a case when this differs for ActionData and PlayerAction? Sounds complex
var backend_animation_name: String
var blend_time: float
var motion_type: LegsSM.MotionType

func _init(
		action_name_: String,
		animation_name_: String,
		backend_anim_name_: String = "",
		blend_time_: float = 0.2,
		motion_type_: LegsSM.MotionType = LegsSM.MotionType.IDLE,
	) -> void:
	self.action_name = action_name_
	self.animation_name = animation_name_
	if backend_anim_name_ == "":
		self.backend_animation_name = A.to_backend_anim(animation_name_)
	else:
		self.backend_animation_name = backend_anim_name_
	self.blend_time = blend_time_
	self.motion_type = motion_type_
