class_name FeelingBar
extends RefCountedLogger


## DOCS
# public functions should be named as if it is jast one bar
# e.g.: set_max_value, not update_max_size_all_bars
# 	or get_custom_min_size_x, not get_container_custom_min_size
# This will help to use an abstraction later

## ===========================================================================
##    FEELING BAR UI SETUP INSTRUCTIONS
## ===========================================================================
# region
## 1. ROOT NODE (MarginContainer)
##    - Layout > Container Sizing:  Horizontal: Shrink Begin | Vertical: Shrink Begin
##    - Layout > Custom Min Size:   (0, 0)
##    - Theme Overrides > Const: Set margins (e.g., Top: 40, Left: 40)
##    - Transform > Scale:          (1, 1) (scaling can lead to blur)
##
## 2. BAR CONTAINERS (e.g., StaminaContainer - MarginContainer)
##    - Layout > Custom Min Size:   x: [INITIAL_WIDTH] (e.g., 300), y: 0
## 	 * NOTE: This sets the visual width in Editor. Code logic uses this to calculate ratio.
##    - Layout > Container Sizing:  Horizontal: Shrink Begin
##    - Theme Overrides > Const: 0 
##
## 3. THE BARS (Back, Ghost, Main - TextureProgressBar)
##    - Layout > Custom Min Size:   x: 0, y: [HEIGHT] (e.g., 25)
## 	 * NOTE: x=0. It allows the bar to shrink if max stats drop.
##    - Layout > Container Sizing:  Horizontal: Fill | Vertical: Fill
## 	 * NOTE: 'Fill' forces the bar to match the Container's width.
##    - TextureProgressBar > Nine Patch Stretch: On
##    - Range > Step:               0 (NOTE for smooth lerp animation)
##    - Mouse > Filter:             Ignore
##
## ===========================================================================
##    TLDR
##    - Code reads Container Width (300) / Max Stat (e.g. 70) = Pixels Per Unit.
##    - To resize, code updates the Container's Custom Min Size.
##    - The Bars (set to Fill) automatically stretch to match.
## ===========================================================================
# endregion


# main bar
var main_bar: TextureProgressBar
## Delayed damage indicator
## shows where health was before damage
var ghost_bar: TextureProgressBar
# background bar. Should not be included in any logic
var _back_bar: TextureProgressBar
# parent of all three bars in a tree
var container: MarginContainer
var config: FeelingBarConfig

var tag: String = ""

var _main_tween: Tween
var _ghost_tween: Tween
var _size_tween: Tween

var _pixels_per_bar: float
var _main_bar_initial_modulate: Color

func _init(
		main_bar_: TextureProgressBar,
		ghost_bar_: TextureProgressBar,
		back_bar_: TextureProgressBar,
		container_: MarginContainer,
		curr_value_: float,
		max_value_: float,
		config_: FeelingBarConfig = null,
		tag_: String = ""
		) -> void:
	self.main_bar = main_bar_
	self.ghost_bar = ghost_bar_
	self._back_bar = back_bar_
	self.container = container_
	self.tag = tag_

	if not container_:
		__log_error("no container. This is critical", "", "FeelingBar won't be working correctly.")
	if not main_bar_:
		__log_error("no main_bar_. This is critical", "", "FeelingBar won't be working correctly.")
	if not ghost_bar_:
		__log_warn_soft("no ghost_bar_")
	if not back_bar_:
		__log_warn_soft("no back_bar_")

	self.config = config_
	if not self.config:
		self.config = FeelingBarConfig.new()

	set_max_value(max_value_)

	if _back_bar:
		_back_bar.step = 0.0

	if main_bar_:
		main_bar.step = 0.0
		main_bar.value = curr_value_
		_main_bar_initial_modulate = main_bar.modulate
	
	if ghost_bar:
		ghost_bar.step = 0.0
		# ghost_bar.texture_progress = main_bar_.texture_progress # Reuse same texture
		ghost_bar.value = curr_value_

	## Supported only once in bar init. (in theory could be recalculated later)
	_calculate_pixels_per_bar()


func _calculate_pixels_per_bar() -> void:
	# get the width u set in the Editor (e.g., 300)
	var current_container_width := get_custom_min_size_x()
	
	# safety check / fallback / ui fix
	if current_container_width <= 0:
		current_container_width = 300.0
		set_custom_min_size_x(current_container_width)
		__log_warn_soft("Container width was 0 in editor. Defaulting to 300.")

	# the ratio (e.g., 300 px / 70 stamina = 4.28 px per unit)
	if get_max_value() > 0:
		_pixels_per_bar = current_container_width / get_max_value()
	else:
		_pixels_per_bar = 4.0 # fallback
	
	__log_("_calculate_pixels_per_bar", "Editor Width:", current_container_width, "_pixels_per_bar:", _pixels_per_bar)


# region: MODULATION AND VISIBILITY

func set_visible(is_visible: bool) -> void:
	if container:
		container.visible = is_visible


func fade_out_and_hide(for_whom: Node) -> void:
	UIUtils.fade_out_and_hide_for_panels(for_whom, _get_existing_bars(), config.fadeout_duration)


func modulate_a(value_: float) -> void:
	if container: container.modulate.a = value_


func main_bar_modulate(value_: Color) -> void:
	if main_bar: main_bar.modulate = value_


func main_bar_modulate_reset() -> void:
	if main_bar and _main_bar_initial_modulate:
		main_bar.modulate = _main_bar_initial_modulate

# endregion


# region: VALUE GETTERS

func get_max_value() -> float:
	## max value is the same for all three bars always
	return _get_bar_max_val(main_bar)


func get_main_bar_value() -> float:
	return _get_bar_val(main_bar)


func get_ghost_bar_value() -> float:
	return _get_bar_val(ghost_bar)


# endregion


# region: VALUE SETTERS


## should be the only way to set max value
func set_max_value(value_: float):
	if main_bar:
		main_bar.max_value = value_
		__log_("set_max_value", "main_bar updated with max value", value_)
	if ghost_bar:
		ghost_bar.max_value = value_
		__log_("set_max_value", "ghost_bar updated with max value", value_)
	if _back_bar:
		_back_bar.max_value = value_
		_back_bar.value = value_ # NOTE: important
		__log_("set_max_value", "_back_bar updated with max value", value_)


func set_main_bar_value(value_: float):
	if is_main_animating():
		__log_warn_soft(pp.s("set_main_bar_value", "called while Tween is running. Val: ", value_))
	_set_bar_value(main_bar, value_, "main_bar")


func set_ghost_bar_value(value_: float):
	if is_ghost_animating():
		__log_warn_soft(pp.s("set_ghost_bar_value", "called while Tween is running. Val: ", value_))
	_set_bar_value(ghost_bar, value_, "ghost_bar")


func animate_main_bar_value_change(for_whom: Node, target_value: float) -> void:
	__log_("animate_main_bar_value_change", __pp_curr_values(), "target_value", str(target_value))

	UIUtils.kill_tween_if_exists(_main_tween)

	_main_tween = UIUtils.animate_property(
		for_whom,
		main_bar,
		"value",
		target_value,
		config.anim_main_bar_dur,
	)
	if _main_tween.is_valid():
		__log_("Main tween Started")
	else:
		__log_("Tween failed to create")


func animate_ghost_bar_value_change(for_whom: Node, from_value: float, to_value: float) -> void:
	__log_("animate_ghost_bar_value_change", __pp_curr_values(), "from_value/to_value", str(from_value), str(to_value))
	UIUtils.kill_tween_if_exists(_ghost_tween)
	
	set_ghost_bar_value(from_value)

	__log_("after set_ghost_bar_value", "curr main value/curr ghost value",
		str(get_main_bar_value()), str(get_ghost_bar_value()))


	_ghost_tween = UIUtils.animate_property(
		for_whom,
		ghost_bar,
		"value",
		to_value,
		config.ghost_dur,
		config.ghost_delay,
		TweenConfig.new(config.ghost_trans, config.ghost_ease)
	)
	if _ghost_tween.is_valid():
		__log_("Ghost tween Started. Waiting", config.ghost_delay, "s then animating to", to_value)
	else:
		__log_("Tween failed to create")

# endregion


func is_ghost_animating() -> bool:
	return _ghost_tween and _ghost_tween.is_valid() and _ghost_tween.is_running()

func is_main_animating() -> bool:
	return _main_tween and _main_tween.is_valid() and _main_tween.is_running()


# region: SIZES


func get_size() -> Vector2:
	if container:
		return container.size
	else:
		return Vector2.ZERO


func get_custom_min_size_x() -> float:
	if container:
		return container.custom_minimum_size.x
	else:
		return -1.0


func set_custom_min_size_x(value_: float):
	if container:
		__log_("set_custom_min_size_x", value_)
		container.custom_minimum_size.x = value_


func scale_xy(multiplier: float) -> void:
	if container:
		container.scale.x *= multiplier
		container.scale.y *= multiplier


func animate_bar_size_increase(increase_delta_: float) -> void:
	if increase_delta_ < 0.0:
		__log_error(" increase_delta_ < 0.0 not supported for now. Dont decrease character feelings / ui bars")
		return

	var new_max_value := get_max_value() + increase_delta_
	var new_width := new_max_value * _pixels_per_bar
	
	__log_("animate_bar_size_increase", "new_max_value/New Width:", new_max_value, new_width)

	set_max_value(new_max_value)
	
	UIUtils.kill_tween_if_exists(_size_tween)
	
	if container:
		_size_tween = container.create_tween()
		
		_size_tween.tween_property(
			container,
			"custom_minimum_size:x",
			new_width,
			0.3
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		_size_tween.tween_callback(func():
				if is_equal_approx(get_custom_min_size_x(), new_width):
					__log_("animate_bar_size_increase ", "Stamina bar resized correctly.")
				else:
					__log_warn(pp.s("animate_bar_size_increase", "Size mismatch!", get_custom_min_size_x(), new_width)
			))

# endregion


# region: INTERNAL

func _get_bar_max_val(bar: TextureProgressBar) -> float:
	if bar:
		return bar.max_value
	else:
		__log_warn("no bar", "_get_bar_max_val", "return -1.0 as max value")
		return -1.0


func _get_bar_val(bar: TextureProgressBar) -> float:
	if bar:
		return bar.value
	else:
		__log_warn("no bar", "_get_bar_val", "return -1.0 as curr value")
		return -1.0


func _set_bar_value(bar: TextureProgressBar, value_: float, context: String = ""):
	if bar:
		var prev_value := bar.value
		bar.value = value_
		if abs(prev_value - value_) > 2.0:
			__log_("_set_bar_value", value_, pp.in_br(pp.s("from", prev_value)), "for", pp.in_q(context))
	else:
		__log_warn("no bar", "_set_bar_value", pp.s("value", value_, "is lost"))


## usually returns all three.
## intentionally is not a public API. three bar system should be hidden in FeelingBar class
func _get_existing_bars() -> Array[TextureProgressBar]:
	var _r: Array[TextureProgressBar] = []
	if main_bar:
		_r.append(main_bar)
	if ghost_bar:
		_r.append(ghost_bar)
	if _back_bar:
		_r.append(_back_bar)
	return _r
	
# endregion



## LOGS

func __pp_curr_values() -> String:
	return pp.s("curr main value/curr ghost value", str(get_main_bar_value()), str(get_ghost_bar_value()))


func pp_name() -> String:
	return pp.s(tag, ObjUtils.construct_obj_pp_name(self ))


func __debug_bar():
	__log_("\n========= DEBUG BAR STATE =========")
	__log_("Main Bar | Val: ", get_main_bar_value(), " / Max: ", get_max_value())
	__log_("Back Bar | Max: ", _back_bar.max_value)
	__log_("Ghost Bar| Val: ", ghost_bar.value)
	__log_("Container| Size X: ", container.size.x)
	__log_("Container| custom min Size X: ", get_custom_min_size_x())
	__log_("===================================\n")


func __LOG_B() -> bool:
	return LogToggler.FEEL.BAR