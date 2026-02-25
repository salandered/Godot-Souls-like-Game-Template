@tool
class_name DVAudioBusSpectrum
extends ControlSystem


@export var audio_bus_name := Const.SFX_ASP_BASE_BUS_ID
@export var preview_in_editor := false
@export_range(4, 64, 4) var bars_count := 16
@export_exp_easing("inout") var motion_smoothing := 0.025
@export_range(0.1, 1.0) var bar_width_ratio := 0.8 # thickness
@export var colors: Gradient = null


var MAX_HZ := 16000.0
var MIN_HZ := 20.0
var MIN_DB := 60.0
var spectrum: AudioEffectSpectrumAnalyzerInstance = null

var smoothed_energy: Array[float] = []
var def_color := Color.HOT_PINK


func __hard_validation() -> bool:
	return AudioServerUtil.bus_exists(audio_bus_name, WL.WARN)


## INITIALISATION

func _ready():
	if eu.is_editor() and not preview_in_editor: return
	if not __perform_validation(true):
		return
		
	smoothed_energy.resize(bars_count)
	smoothed_energy.fill(0.0)

	_init_spectrum_effect(audio_bus_name)


func _init_spectrum_effect(bus_id: StringName):
	AudioServerUtil.ensure_spectrum_analyzer(bus_id)
	spectrum = AudioServerUtil.get_spectrum_analyzer_instance(bus_id)
	

func _reset_visuals():
	smoothed_energy.fill(0.0) # clear data so bars drop to bottom
	queue_redraw() # force one last draw to show the "flatline"


## PUBLIC

func set_enabled(value: bool) -> void:
	if not __validation_ok():
		return
	set_process(value)
	if not value:
		_reset_visuals()


## returns false if failed
func set_audio_bus(new_bus_name: StringName) -> bool:
	if not __validation_ok():
		return false
	if audio_bus_name == new_bus_name:
		return false
	if not AudioServerUtil.bus_exists(new_bus_name):
		__log_warn_soft("new_bus_name does not exist", "", "", new_bus_name)
		return false

	audio_bus_name = new_bus_name
	_init_spectrum_effect(audio_bus_name)

	_reset_visuals()
	return true


## PROCESS

func _process(delta):
	if eu.is_editor() and not preview_in_editor: return
	if not __validation_ok(): return
	if not spectrum: return
	
	if smoothed_energy.size() != bars_count:
		smoothed_energy.resize(bars_count)
		smoothed_energy.fill(0.0)

	_process_audio_data(delta)

	# schedule update
	queue_redraw()


## called when CanvasItem has been requested to redraw
func _draw():
	if not spectrum: return

	# calculate shared layout metrics
	var layout := _calc_layout_metrics()

	# draw components
	_draw_bars(layout)
	_draw_labels(layout)


func _calc_layout_metrics() -> Dictionary:
	var text_h := 20.0 # Height reserved for labels
	
	var total_width := size.x
	var bar_w_step := total_width / float(bars_count)
	var actual_bar_w := bar_w_step * bar_width_ratio
	
	return {
		# Bars usually draw from bottom up. 
		# We lower the "floor" of the bars by subtracting text_h from total size.
		"total_height": size.y - text_h,
		"text_height": text_h,
		"step_width": bar_w_step,
		"bar_width": actual_bar_w,
		"margin": (bar_w_step - actual_bar_w) / 2.0
	}


func _draw_bars(layout_dict: Dictionary) -> void:
	for bar_idx in range(bars_count):
		var energy: float = smoothed_energy[bar_idx]
		# Scale height to the available bar area (excluding text area)
		var height: float = energy * layout_dict.total_height
		
		var rect := Rect2(
			bar_idx * layout_dict.step_width + layout_dict.margin,
			# Draw from the "bar floor" upwards
			layout_dict.total_height - height,
			layout_dict.bar_width,
			height
		)
		
		# calc color
		var final_color := def_color
		if colors:
			final_color = colors.sample(float(bar_idx) / float(bars_count))
			final_color.s = clamp(final_color.s - energy * 0.3, 0, 1.0)
		
		draw_rect(rect, final_color)


func _draw_labels(layout_dict: Dictionary) -> void:
	var font := get_theme_default_font()
	var font_size := 22
	
	var label_step := maxi(1, int(bars_count / 8.0))

	for bar_idx: int in range(0, bars_count, label_step):
		var freq_hz := _get_freq_at_index(bar_idx, 0.5)
		var text := _format_freq_text(freq_hz)
		
		# measure text width
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		
		# calculate absolute center X of the bar
		var center_x: float = (bar_idx * layout_dict.step_width + layout_dict.margin) + (layout_dict.bar_width / 2.0)
		
		# position text: X - centered on bar; Y - Bottom of the control (size.y) minus padding
		var draw_pos := Vector2(
			center_x - (text_size.x / 2.0),
			size.y - 4 # 4px padding
		)
		
		draw_string(font, draw_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)


func _process_audio_data(delta: float):
	var prev_hz = MIN_HZ
	
	for bar_idx in range(bars_count):
		var ih = bar_idx + 1
		var hz: float = MathUtils.lerp_log(MIN_HZ, MAX_HZ, ih / float(bars_count))


		var magnitude: float = spectrum.get_magnitude_for_frequency_range(
			prev_hz,
			hz,
			AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE
		).length()

		var db := linear_to_db(magnitude) if magnitude > 0.00001 else -MIN_DB
		var energy: float = clampf((MIN_DB + db) / MIN_DB, 0, 1)
		
		# smooth the movement
		var e: float = lerp(
			smoothed_energy[bar_idx],
			energy,
			clampf(delta / motion_smoothing if motion_smoothing else 1.0, 0, 1)
		)
		smoothed_energy[bar_idx] = e
		
		prev_hz = hz


func _get_freq_at_index(i: int, offset: float = 1.0) -> float:
	# map index to log scale frequency
	var t := float(i + offset) / float(bars_count)
	return MathUtils.lerp_log(MIN_HZ, MAX_HZ, t)


func _format_freq_text(hz: float) -> String:
	var rounded_hz := snappedf(hz, 10.0)
	
	if rounded_hz >= 1000:
		return "%.1fk" % (rounded_hz / 1000.0)
		
	return "%d" % rounded_hz
