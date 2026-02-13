@tool
class_name EnemyMetricsGridManager
extends BaseMetricsGridManager

var _e_movement: EnemyMovement


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_e_movement
	]


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.ENEMY_MOVEMENT_INFO


func nth_frame() -> int:
	return 5


func initialise_implementation() -> void:
	super.initialise_implementation()
	var _enemy := Groups.get_first_phe_bg_by_group_with_tag(self , "demo_enemy")

	if _enemy:
		_e_movement = _enemy.get_e_movement()


func _process_implementation(delta: float) -> void:
	if not _e_movement: return

	_update_enemy_metrics()


func _update_enemy_metrics() -> void:
	var e_m := _e_movement

	var dist := e_m.distance_to_player()
	
	var angle_deg := float(pp.rad2deg(e_m.signed_angle_to_player(), false))
	
	_metrics_grid.update_metric(
		"Dist / Angle to Player",
		"%4.1f | %4.1f°" % [dist, angle_deg]
	)

	_metrics_grid.update_metric(
		"Velocity",
		e_m.get_curr_velocity()
	)

	_metrics_grid.update_metric(
		"Is Falling",
		e_m.is_actively_falling()
	)
