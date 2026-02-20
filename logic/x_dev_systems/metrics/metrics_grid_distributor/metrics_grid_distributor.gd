class_name MetricsGridDistributor
extends NodeSystem


@export var grid: GridContainer
@export var fade_duration: float = 0.4

@export_category("Color S")
@export var modulate_name_label: Color = def_modulate_name_label

@export_category("Font S")
@export var value_label_mono_font: Font
## will be used if set
@export var use_value_label_mono_font: bool = true
@export var value_label_font_size: int = 24
@export var name_label_font_size: int = 24

@export_category("Grid S")
@export var show_ghost_on_change: bool = false

## by default dim the key
const def_modulate_name_label := Color(0.7, 0.7, 0.7)

# maps metric name -> value label node
var _rows: Dictionary[String, Label] = {}
var _fading_rows: Dictionary = {}

func __hard_dependencies() -> Array:
	return [
		grid
	]

func _ready() -> void:
	if grid:
		grid.columns = 2


func _process(delta: float) -> void:
	if _fading_rows.is_empty(): return
	
	var keys := _fading_rows.keys()
	for key: String in keys:
		if not _rows.has(key):
			continue

		var label: Label = _rows[key]
		
		label.modulate.a -= delta / max(fade_duration, 0.1)
		
		if label.modulate.a <= 0.0:
			label.text = "" # clear the text finally
			label.modulate.a = 1.0
			_fading_rows.erase(key)


## auto creates new metric if no key found
func update_metric(
	metric_name: String,
	metric_value: Variant,
	fmt_show_vector_len: bool = true,
	delta_font_size: int = 0
) -> void:
	if not _rows.has(metric_name):
		__log_("update_metric", metric_name)
		_rows[metric_name] = _create_new_row(metric_name, delta_font_size)
	
	var metric_label: Label = _rows[metric_name]
	var new_text := pp.metric_fmt(metric_value, fmt_show_vector_len)
	var is_empty := (new_text == "") # or new_text == "[]")
	
	if not is_empty:
		if show_ghost_on_change and metric_label.text != "" and metric_label.text != new_text:
			_spawn_ghost_change(metric_label)
		metric_label.text = new_text
		metric_label.modulate.a = 1.0
		_fading_rows.erase(metric_name) # stop fading if we were
		
	else:
		if metric_label.text != "" and not _fading_rows.has(metric_name):
			_fading_rows[metric_name] = true


func _create_new_row(key: String, delta_font_size: int = 0) -> Label:
	var name_label := Label.new()
	name_label.text = key
	name_label.modulate = modulate_name_label if modulate_name_label else def_modulate_name_label

	var value_label := Label.new()
	if use_value_label_mono_font and value_label_mono_font:
		ControlUtils.label_set_font(value_label, value_label_mono_font)

	ControlUtils.label_set_font_size(value_label, value_label_font_size + delta_font_size)
	ControlUtils.label_set_font_size(name_label, name_label_font_size + delta_font_size)

	grid.add_child(name_label)
	grid.add_child(value_label)
	
	return value_label


func _spawn_ghost_change(target: Label) -> void:
	var ghost := Label.new()
	ghost.text = target.text
	ghost.modulate = target.modulate
	# copy font configuration if needed, or rely on theme
	if use_value_label_mono_font and value_label_mono_font:
		ControlUtils.label_set_font(ghost, value_label_mono_font)
	
	# match font size of the specific target row
	var target_font_size = target.get_theme_font_size("font_size")
	if target_font_size > 0:
		ControlUtils.label_set_font_size(ghost, target_font_size)

	# add to tree but ignore layout
	add_child(ghost)
	ghost.top_level = true
	
	# Start at the right edge of the current label
	# We use a small buffer (+10) to separate it from the new value
	var start_pos := target.global_position
	start_pos.x += target.size.x + 10.0
	ghost.global_position = start_pos
	
	var tween := create_tween()
	tween.set_parallel(true)
	# Fade out
	tween.tween_property(ghost, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Drift right
	tween.tween_property(ghost, "position:x", start_pos.x + 40.0, 0.8)
	
	tween.chain().tween_callback(ghost.queue_free)


func __LOG_B() -> bool:
	return false
