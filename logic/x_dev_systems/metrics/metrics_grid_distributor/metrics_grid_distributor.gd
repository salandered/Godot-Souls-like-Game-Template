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

## by default dim the key slightly
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
func update_metric(metric_name: String, metric_value: Variant, fmt_show_vector_len: bool = true) -> void:
	if not _rows.has(metric_name):
		__log_("update_metric", metric_name)
		_rows[metric_name] = _create_new_row(metric_name)
	
	var metric_label: Label = _rows[metric_name]
	var new_text := pp.metric_fmt(metric_value, fmt_show_vector_len)
	var is_empty := (new_text == "") # or new_text == "[]")
	
	if not is_empty:
		metric_label.text = new_text
		metric_label.modulate.a = 1.0
		_fading_rows.erase(metric_name) # stop fading if we were
		
	else:
		if metric_label.text != "" and not _fading_rows.has(metric_name):
			_fading_rows[metric_name] = true


func _create_new_row(key: String) -> Label:
	var name_label := Label.new()
	name_label.text = key
	name_label.modulate = modulate_name_label if modulate_name_label else def_modulate_name_label

	var value_label := Label.new()
	if use_value_label_mono_font and value_label_mono_font:
		ControlUtils.label_set_font(value_label, value_label_mono_font)

	ControlUtils.label_set_font_size(value_label, value_label_font_size)
	ControlUtils.label_set_font_size(name_label, name_label_font_size)
	grid.add_child(name_label)
	grid.add_child(value_label)
	
	return value_label


func __LOG_B() -> bool:
	return false
