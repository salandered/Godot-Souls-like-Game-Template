extends BasePlayerState
## This class is a move that also has a lower torso behavior working as a separate SM
class_name TorsoPartialMove


@export var legs_behaviour: LegsBehaviour

func process_input_vector(input, delta):
	legs_behaviour.current_legs_state.process_input_vector(input, delta)

# Danger zone, overrides an internal method of base class BasePlayerState.
# Only adds new lines and calls the base implementation.
func _update(input: InputPackage, delta: float):
	# skeleton.add_torso_correction(x_adjustment, y_adjustment, z_adjustment)
	legs_behaviour.update(input, delta)
	# TODO TODO CHECK ???
	update(input, delta)


func _on_enter_state():
	#skeleton.add_torso_correction(x_adjustment, y_adjustment, z_adjustment)
	super._on_enter_state()


func _on_exit_state():
	#skeleton.remove_torso_correction()
	super._on_exit_state()
