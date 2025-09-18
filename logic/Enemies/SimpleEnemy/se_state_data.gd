extends Resource
class_name SEStateData


var state_name: String
var animation_name: String
var backend_animation_name: String
var global_commitment: float = 5.0
## one iteration commitment
var iteration_commitment: float = 0.1 # may be length of animation
var fatigue: float = 10

func _init(
	state_name_: String,
	animation_name_: String,
	backend_animation_name_: String = "",
	global_commitment_: float = 5.0,
	iteration_commitment_: float = 0.1,
	fatigue_: float = 10
	) -> void:
	self.state_name = state_name_
	self.animation_name = animation_name_
	if backend_animation_name_ == "":
		# TODO: _params is legacy. we use -params
		self.backend_animation_name = animation_name_ + "_param"
	else:
		self.backend_animation_name = backend_animation_name_

	self.global_commitment = global_commitment_
	self.iteration_commitment = iteration_commitment_
	self.fatigue = fatigue_
