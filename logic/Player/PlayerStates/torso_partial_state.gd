extends BasePlayerState
## This class is a state that also has a lower torso behavior working as a separate SM
class_name TorsoPartialState


# from enemy 4
@export_group("torso_adjustment")
@export var x_adjustment: float
@export var y_adjustment: float
@export var z_adjustment: float

## lower torso behavior working as a separate SM
@export var legs_behaviour: LegsBehaviour

## Calling legs behavior to update on update tick.
##    - overrides BasePlayerState method
##    - but current_legs_state is BasePlayerState
##      => calls process_input_vector of a usual state,
##         which is default BasePlayerState or specific state's implementation
func process_input_vector(input, delta):
	legs_behaviour.current_legs_state.process_input_vector(input, delta)


## Overrides an internal method of BasePlayerState!
## Only adds new lines and calls the base implementation.
func _update(input: InputPackage, delta: float):
	# skeleton.add_torso_correction(x_adjustment, y_adjustment, z_adjustment)
	legs_behaviour.update(input, delta)
	# TODO TODO CHECK ???
	update(input, delta)

	# in enhemy4
	# legs_behaviour.update(input, delta)
	# super._update(input, delta)


func _on_enter_state():
	#skeleton.add_torso_correction(x_adjustment, y_adjustment, z_adjustment)
	super._on_enter_state()


func _on_exit_state():
	#skeleton.remove_torso_correction()
	super._on_exit_state()
