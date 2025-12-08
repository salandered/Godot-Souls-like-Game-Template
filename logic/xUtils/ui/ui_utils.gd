extends RefCounted
class_name UIUtils

const ALPHA_CHANNEL = "modulate:a"


static func fade_out_and_hide(owner: Node, ui_panels: Array, duration: float) -> Tween:
	var tween = owner.create_tween()
	tween.set_parallel(true)
	
	for panel: Control in ui_panels:
		tween.tween_property(
			panel,
			ALPHA_CHANNEL,
			0.0,
			duration
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# After fade completes, hide the UI
	tween.chain().tween_callback(func():
		for panel in ui_panels:
			panel.visible = false
	)
	
	return tween


static func start_pulse(node: Control, min_alpha: float, duration: float) -> Tween:
	var tween = node.create_tween().set_loops()
	tween.tween_property(
		node,
		ALPHA_CHANNEL,
		min_alpha,
		duration * 0.5
	).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		node,
		ALPHA_CHANNEL,
		1.0,
		duration * 0.5
	).set_trans(Tween.TRANS_SINE)
	return tween


static func stop_pulse(node: Control, tween: Tween) -> void:
	if tween:
		tween.kill()
	node.modulate.a = 1.0


## Animate with delay - useful for "ghost" or "lagging" indicators
static func animate_property(
	owner: Node,
	target: Object,
	property: String,
	final_value: Variant,
	duration: float,
	delay: float = -1.0,
	tween_config: TweenConfig = null
) -> Tween:
	if not tween_config:
		tween_config = TweenConfig.new()

	var tween = owner.create_tween()
	
	if not delay == -1.0:
		tween.tween_interval(delay)

	tween.tween_property(
		target,
		property,
		final_value,
		duration) \
		.set_trans(tween_config.trans_type) \
		.set_ease(tween_config.ease_type)
	
	return tween

static func kill_tween_if_exists(tween: Tween):
	if tween:
		tween.kill()
