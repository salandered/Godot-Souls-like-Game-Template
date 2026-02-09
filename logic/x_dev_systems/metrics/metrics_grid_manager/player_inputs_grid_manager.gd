class_name InputsMetricGridManager
extends BaseMetricsGridManager


var _player_movement: PlayerMovement


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_player_movement
	]


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.PLAYER_INPUT_INFO


func _ready_imp() -> void:
	super._ready_imp()

	var _r_players := get_tree().get_nodes_in_group(Groups.Chars.PLAYER)
	if len(_r_players) == 1 and _r_players[0] is Princess:
		var _pl := _r_players[0] as Princess
		_player_movement = _pl.get_pl_movement()


func _process(delta: float) -> void:
	var input := InputManager.get_current_input()
	
	_update_input_package_metrics(input, delta)


func _update_input_package_metrics(input: InputPackage, delta: float) -> void:
	if not _metrics_grid: return
	if not _player_movement: return


	_metrics_grid.update_metric("Vector", input.input_direction)
	_metrics_grid.update_metric("Ver/Hor Strength", Vector2(input.forward_input, input.orbit_input))
	# var vbyi := _player_movement.velocity_by_input(input, delta)
	# _metrics_grid.update_metric("Vel by Input", vbyi)
	
	var apli := _player_movement.get_signed_angle_pl_input(input, delta)
	_metrics_grid.update_metric("∠(Player,Input)", pp.rad2deg(apli))

	var strafe = input.detect_strafe_dir()
	_metrics_grid.update_metric("Strafe Dir", Direction.name_(strafe))
	var drtf := _player_movement.detect_dir_relative_to_facing(input, delta)
	_metrics_grid.update_metric("Dir relative to facing", Direction.name_(drtf))
	

	# _metrics_grid.update_metric("Target Lock", input.target_lock)
	# _metrics_grid.update_metric("Actions", input.actions)
