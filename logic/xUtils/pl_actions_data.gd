extends Resource
class_name PlayerActionData

var state_name: String
var action_name: String
var animation_name: String
var backend_animation_name: String
# var animator_set: String
var blend_time: float
var dummy: bool

func _init(
		state_name_: String,
		action_name_: String,
		animation_name_: String,
		backend_anim_name_: String = "",
		blend_time_: float = 0.2,
		dummy_: bool = false,
		# animator_set_: String = ""
	) -> void:
	self.state_name = state_name_
	self.action_name = action_name_
	self.animation_name = animation_name_
	if backend_anim_name_ == "":
		self.backend_animation_name = animation_name_ + "-param"
	else:
		self.backend_animation_name = backend_anim_name_
	# if animator_set_ == "":
	# 	self.animator_set = "full_body"
	# else:
	# 	self.animator_set = animator_set_
	self.blend_time = blend_time_
	self.dummy = dummy_