@tool
class_name EnemyAnimMetricsGridManager
extends BaseMetricsGridManager

var _animator: EnemyAnimatorManager
var _overlay_modifier: OverlayModifier


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_animator
	]


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.ENEMY_ANIMATOR


func nth_frame() -> int:
	return 5


func initialise_implementation() -> void:
	super.initialise_implementation()
	var _enemy := Groups.get_first_phe_bg_by_group_with_tag(self , "demo_enemy")
	if _enemy:
		_animator = _enemy.get_animator_manager()
		if _animator:
			_overlay_modifier = _animator.overlay_modifier


func _process_implementation(delta: float) -> void:
	if not _animator: return

	_update_animator_metrics()


func _update_animator_metrics() -> void:
	if not _animator: return
	if not _overlay_modifier: return
	
	var anim_id := _animator.get_curr_anim_id()
	if anim_id.is_empty():
		anim_id = " - "
		
	_metrics_grid.update_metric("Animation", pp.anim_n(anim_id, true))


	var overlay_anim := ""
	var co := _overlay_modifier.curr_overlay
	if co and co.playback:
		if co.curr_weight <= 0.0:
			overlay_anim = ""
		else:
			overlay_anim = co.playback.anim.anim_name

	_metrics_grid.update_metric(
		"Overlay anim",
		overlay_anim,
		false,
		)

	var time_spent := _animator.get_curr_anim_time_spent()
	var duration := _animator.get_curr_anim_effective_duration()
	var raw_pos := _animator.get_curr_anim_position_unscaled()
	
	_metrics_grid.update_metric(
		"Time spent | Duration | Start offset",
		"%4.1f | %4.1f | %4.1f" % [
			time_spent,
			duration,
			_animator._curr_anim_start_offset])


	var anim_scale := 1.0
	var curr_anim_data = _animator.get_curr_anim()
	if curr_anim_data:
		anim_scale = curr_anim_data.speed_scale

	var state_scale := 1.0
	if _animator._native_player:
		state_scale = _animator._native_player.speed_scale
	_metrics_grid.update_metric(
		"Speed scale - State mult | Anim mult | Final",
		"%4.2f | %4.2f | %4.2f" % [
			state_scale,
			anim_scale,
			_animator.get_global_speed_scale(),
			],
			true,
			15,
			18)


	# root motion vector being applied this frame
	var rm_pos := _animator.get_root_motion_position(false)
	
	_metrics_grid.update_metric(
		"Root Motion",
		rm_pos
	)
