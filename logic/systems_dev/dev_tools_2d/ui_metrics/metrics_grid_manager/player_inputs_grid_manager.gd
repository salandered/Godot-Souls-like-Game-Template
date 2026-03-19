@tool
class_name InputsMetricGridManager
extends BaseMetricsGridManager


var _player_movement: PlayerMovement


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_player_movement
	]


func get_dtc_op_key() -> DTS.KeyBOverlayPanel:
	return DTS.KeyBOverlayPanel.PLAYER_INPUT_INFO


func initialize_implementation() -> void:
	super.initialize_implementation()

	var _pl := Groups.get_player_by_group(self )
	if _pl:
		_player_movement = _pl.get_pl_movement()


func _process_implementation(delta: float) -> void:
	var input := InputManager.get_current_input()
	
	_update_input_package_metrics(input, delta)


func _update_input_package_metrics(input: InputPackage, delta: float) -> void:
	if not _player_movement: return

	_metrics_grid.update_metric("Vector", input.input_direction)
	_metrics_grid.update_metric("Ver/Hor Strength", Vector2(input.forward_input, input.orbit_input))
	# var vbyi := _player_movement.velocity_by_input(input, delta)
	# _metrics_grid.update_metric("Vel by Input", vbyi)
	
	var apli := _player_movement.get_signed_angle_pl_input(input, delta)
	_metrics_grid.update_metric("∠(Player,Input)", "%5.2f°" % [pp.frad2deg(apli)])

	var strafe = input.detect_strafe_dir()
	_metrics_grid.update_metric("Strafe Dir", Direction.name_(strafe))
	var drtf := _player_movement.detect_dir_relative_to_facing(input, delta)
	_metrics_grid.update_metric("Dir relative to facing", Direction.name_(drtf))
	

	# _metrics_grid.update_metric("Target Lock", input.target_lock)
	# _metrics_grid.update_metric("Actions", input.actions)
