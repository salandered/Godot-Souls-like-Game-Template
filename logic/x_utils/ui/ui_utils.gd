extends RefCountedStaticLogger
class_name UIUtils


static func fade_out_and_hide_for_panels(for_whom: Node, ui_panels: Array, duration: float) -> Tween:
	if not for_whom:
		return

	var tween := for_whom.create_tween()
	tween.set_parallel(true)
	
	for panel: Control in ui_panels:
		if panel:
			tween.tween_property(
				panel,
				PropC.MODULATE_A,
				0.0,
				duration
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
	# After fade completes, hide the UI
	tween.chain().tween_callback(func():
		for panel in ui_panels:
			if panel: panel.visible = false
	)
	
	return tween


static func start_pulse(for_whom: Control, min_alpha: float, duration: float) -> Tween:
	if not for_whom:
		return

	var tween := for_whom.create_tween().set_loops()
	tween.tween_property(
		for_whom,
		PropC.MODULATE_A,
		min_alpha,
		duration * 0.5
	).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		for_whom,
		PropC.MODULATE_A,
		1.0,
		duration * 0.5
	).set_trans(Tween.TRANS_SINE)
	return tween


static func stop_pulse(for_whom: Control, tween: Tween) -> void:
	if not for_whom:
		return
	if tween:
		tween.kill()
	for_whom.modulate.a = 1.0


## Animate with delay - useful for "ghost" or "lagging" indicators
static func animate_property(
	for_whom: Node,
	target: Object,
	property: String,
	final_value: Variant,
	duration: float,
	delay: float = -1.0,
	tween_config: TweenConfig = null
) -> Tween:
	__log_("animate_property", "property/final_value/dur/delay", property, str(final_value), duration, delay)
	if not for_whom:
		return
		
	if not tween_config:
		tween_config = TweenConfig.new()

	var tween := for_whom.create_tween()
	
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


## Fades a list of targets out, executes callback, then fades them back in.
static func animate_content_change(
	for_whom: Node,
	targets: Array[Control],
	change_callback: Callable,
	duration: float,
	tween_config: TweenConfig = null
) -> Tween:
	if not for_whom or targets.is_empty():
		return null
		
	if not tween_config:
		tween_config = TweenConfig.new()

	var tween := for_whom.create_tween()
	tween.set_parallel(true) # Animate all targets together
	
	# fade out all
	for target in targets:
		if target:
			tween.tween_property(target, PropC.MODULATE_A, 0.0, duration) \
				.set_trans(tween_config.trans_type) \
				.set_ease(tween_config.ease_type)
		
	# Change Content (Chain ensures this happens after fades finish)
	tween.chain().tween_callback(change_callback)
	
	# fade in all
	for target in targets:
		if target:
			tween.tween_property(target, PropC.MODULATE_A, 1.0, duration) \
				.set_trans(tween_config.trans_type) \
				.set_ease(tween_config.ease_type)
		
	return tween


# region: __LOGS
static func pp_name() -> String:
	return ">> UIUtils"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion
