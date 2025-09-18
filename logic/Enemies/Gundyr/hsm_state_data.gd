extends Resource
class_name HSMEStateData


var state_name: String
## NOTE: In HSM can be empty "" for phases
var animation_name: String
var backend_animation_name: String

func _init(
	state_name_: String,
	animation_name_: String,
	backend_animation_name_: String = "",
	) -> void:
	self.state_name = state_name_
	self.animation_name = animation_name_
	if backend_animation_name_ == "":
		# TODO: _backend is legacy. we use -param
		self.backend_animation_name = animation_name_ + "_backend"
	else:
		self.backend_animation_name = backend_animation_name_
