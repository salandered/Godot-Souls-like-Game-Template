extends Resource
class_name PlayerActionData

var state_name: String
var action_name: String
var animation_name: String
var backend_animation_name: String
var blend_time: float
var dummy: bool

func _init(
		state_name_: String,
		action_name_: String,
		animation_name_: String,
		backend_anim_name_: String = "",
		blend_time_: float = 0.2,
		dummy_: bool = false,
	) -> void:
	self.state_name = state_name_
	self.action_name = action_name_
	self.animation_name = animation_name_
	if backend_anim_name_ == "":
		self.backend_animation_name = A.to_backend_anim(animation_name_)
	else:
		self.backend_animation_name = backend_anim_name_

	self.blend_time = blend_time_
	self.dummy = dummy_