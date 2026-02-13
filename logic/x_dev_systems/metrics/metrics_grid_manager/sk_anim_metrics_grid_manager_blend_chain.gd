@tool
class_name SkAnimBlendChainMetricsGridManager
extends BaseMetricsGridManager

var _animator: PlayerModifierAnimator
var _overlay_modifier: OverlayModifier

var _blend_chain: PackedStringArray = []
var _blend_size: int = 0


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
	_blend_chain.resize(4)
	_blend_chain.fill("")
	_animator = Groups.get_first_pl_mod_animator_by_group(self )
	var pl := Groups.get_player_by_group(self )
	if pl:
		var am := pl.get_animator_manager()
		if am:
			_overlay_modifier = am.overlay_modifier


func _process_implementation(delta: float) -> void:
	if not _animator: return
	
	_update_animator_metrics()


func _update_animator_metrics() -> void:
	var _a := _animator

	## blend playbacks always exist (see PlayerModifierAnimator)
	if not _a \
		or not _a.curr_playback:
		return

	if not _overlay_modifier:
		return

	_calculate_blend_chain_and_size()


	_metrics_grid.update_metric(
		"Blending Chain. Size:",
		_blend_size,
		)
	_metrics_grid.update_metric(
		"Current animation",
		_blend_chain[0],
		)
	_metrics_grid.update_metric(
		"Chain anim #1",
		_blend_chain[1],
		true,
		15
		)
	_metrics_grid.update_metric(
		"Chain anim #2",
		_blend_chain[2],
		true,
		15
		)
	_metrics_grid.update_metric(
		"Chain anim #3",
		_blend_chain[3],
		true,
		15
		)


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
		)


func _calculate_blend_chain_and_size():
	_blend_size = 0
	
	_blend_chain[0] = _animator.curr_playback.anim.anim_name # A
	
	if _animator.curr_blend_playback.is_blending and _animator.prev_playback:
		_blend_chain[1] = _animator.prev_playback.anim.anim_name # B
		_blend_size += 1
	else:
		_blend_chain[1] = ""

	if _animator.prev_blend_playback.is_blending and _animator.prev_prev_playback:
		_blend_chain[2] = _animator.prev_prev_playback.anim.anim_name # C
		_blend_size += 1
	else:
		_blend_chain[2] = ""
	
	if _animator.prev_prev_blend_playback.is_blending and _animator.prev_prev_prev_playback:
		_blend_chain[3] = _animator.prev_prev_prev_playback.anim.anim_name # D
		_blend_size += 1
	else:
		_blend_chain[3] = ""
