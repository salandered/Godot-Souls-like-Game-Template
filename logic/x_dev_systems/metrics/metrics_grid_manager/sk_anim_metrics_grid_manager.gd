@tool
class_name SkAnimMetricsGridManager
extends BaseMetricsGridManager

var _animator: PlayerModifierAnimator


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_animator
	]


func get_dvc_op_key() -> DVS.KeyBOverlayPanel:
	return DVS.KeyBOverlayPanel.PLAYER_SK_ANIMATOR


func nth_frame() -> int:
	return 5


func initialise_implementation() -> void:
	super.initialise_implementation()
	
	_animator = Groups.get_first_pl_mod_animator_by_group(self )


func _process_implementation(delta: float) -> void:
	if not _animator: return
	
	_update_animator_metrics()


func _update_animator_metrics() -> void:
	var cp := _animator.curr_playback
	var cbp := _animator.curr_blend_playback
	var r_a := _animator.root_animator

	if not _animator \
		or not cp \
		or not cbp:
		return


	if cp.anim:
		_metrics_grid.update_metric(
			"Animation",
			cp.anim.anim_name
			)


	_metrics_grid.update_metric(
		"Time spent | Duration | Start offset",
		"%4.1f | %4.1f | %4.1f" % [
			cp.time_spent,
			cp.get_effective_duration(),
			cp.start_offset])
	
	if cp.anim:
		var anim_speed_scale = cp.anim.speed_scale
		_metrics_grid.update_metric(
		"Speed scale - State mult | Anim mult | Final",
			"%4.2f | %4.2f | %4.2f" % [
				_animator.global_speed_scale,
				anim_speed_scale,
				_animator._EFFECTIVE_SPEED_SCALE(cp)],
				true,
				15,
				18
				)
	
	_metrics_grid.update_metric("Blending | Progress",
		"%s | %4.1f%%" % [
			"Yes" if cbp.is_blending else "No ",
			cbp.percentage])


	if r_a:
		_metrics_grid.update_metric(
		"Root Motion",
		r_a.get_root_velocity(false))
		_metrics_grid.update_metric(
		"Root Rotation",
		r_a.get_root_rotation())
