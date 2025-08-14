extends Resource
class_name PlayerStateData


var state_name: String
var animation_name: String
var backend_animation_name: String
var animator_set: String

func _init(
		state_name_: String,
		animation_name_: String,
		backend_anim_name_: String = "",
		animator_set_: String = ""
	) -> void:
	self.state_name = state_name_
	self.animation_name = animation_name_
	if backend_anim_name_ == "":
		self.backend_animation_name = animation_name_ + "-param"
	else:
		self.backend_animation_name = backend_anim_name_
	if animator_set_ == "":
		self.animator_set = "full_body"
	else:
		self.animator_set = animator_set_