@tool
extends Control
class_name DynamicInfoLabel


@export_group("Text Config")
@export var description_text: String = "State":
	set(value):
		description_text = value
		_update_desc()

@export var font_size: int = 30:
	set(value):
		font_size = value
		_update_font_size()


@export_group("Color")
@export var gradient_color_modulate: Color = Color.WHITE:
	set(value):
		gradient_color_modulate = value
		_update_gradient_color_modulate()
# 481317

@export_group("Margins inside the panel")
@export var margin_h: int = 15:
	set(value):
		margin_h = value
		_update_margins()

@export var margin_v: int = 10:
	set(value):
		margin_v = value
		_update_margins()


@export_group("Prev text animation")
@export var auto_drop_height: bool = true
## ignored if auto_drop_height true
@export var drop_distance: float = 20.0
@export var drop_buffer: float = 2.0
@export var drop_duration: float = 0.3
@export var wait_duration: float = 0.5
@export var fade_duration: float = 0.3
@export var ghost_target_color: Color = Color(0.6, 0.6, 0.6, 1.0) # Dim gray


@onready var margin_inside_panel: MarginContainer = %MarginInsidePanel
@onready var _desc_label: RichTextLabel = %Desc
@onready var _text_label: RichTextLabel = %Text
@onready var panel_gradient: PanelContainer = %PanelGradient


var _active_ghosts: Array[RichTextLabel] = []
var initial_font_size: int


func _ready() -> void:
	initial_font_size = font_size
	_update_desc()
	_update_font_size()
	_update_gradient_color_modulate()
	_update_margins()

	if not Engine.is_editor_hint():
		reset_text()


func reset_text() -> void:
	set_label_text("", null)
	_active_ghosts = []


func set_label_text(new_text: String, dynamic_label_config: DynamicLabelConfig = null) -> void:
	_set_label_text(_active_ghosts, _text_label, new_text, dynamic_label_config)


func _set_label_text(
	ghosts_list: Array[RichTextLabel],
	label: RichTextLabel,
	new_text: String,
	dynamic_label_config: DynamicLabelConfig
) -> void:
	if not label:
		return
	if not dynamic_label_config:
		dynamic_label_config = DynamicLabelConfig.new()

	if not Engine.is_editor_hint():
		if dynamic_label_config.animate_prev:
			_spawn_ghost_text(ghosts_list, label, label.text, dynamic_label_config)

	if dynamic_label_config.override_color != Color(0, 0, 0):
		label.modulate = dynamic_label_config.override_color
	else:
		label.modulate = Color.WHITE

	if dynamic_label_config.from_snake_case:
		new_text = StrUtils.snake_to_sentence(new_text)

	_adjust_font_size(label, new_text)

	if dynamic_label_config.in_bold:
		new_text = "[b]" + new_text + "[/b]"

	label.text = new_text


func _adjust_font_size(label: RichTextLabel, new_text: String):
	var _size := initial_font_size
	if len(new_text) > 18:
		_size = int(0.75 * _size)
	elif len(new_text) > 14:
		_size = int(0.85 * _size)
	elif len(new_text) > 12:
		_size = int(0.9 * _size)
	if label:
		UIUtils.rr_label_set_font_size(label, _size)


func _spawn_ghost_text(
	ghosts_list: Array[RichTextLabel],
	label: RichTextLabel,
	text_content: String,
	dynamic_label_config: DynamicLabelConfig
) -> void:
	var ghost: RichTextLabel = label.duplicate()
	ghost.text = text_content
	add_child(ghost)
	ghost.top_level = true # break canvas item relationship
	ghost.global_position = label.global_position


	if dynamic_label_config.adjust_prev_font_size:
		UIUtils.rr_label_mult_font_size(ghost, 0.9)

	var shift_amount: float = drop_distance
	if auto_drop_height:
		shift_amount = ghost.size.y + drop_buffer

	## -1 -1 -> backwards
	for i in range(ghosts_list.size() - 1, -1, -1):
		if not is_instance_valid(ghosts_list[i]):
			ghosts_list.remove_at(i)

	# PUSH DOWN all ghosts
	for active_ghost in ghosts_list:
		var push_tween = create_tween()
		var current_y = active_ghost.global_position.y
		
		# NOTE: overrides any existing Y-movement on the ghost
		push_tween.tween_property(
			active_ghost,
			Constants.Prop.GLOBAL_POSITION_Y,
			current_y + shift_amount, drop_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	ghosts_list.append(ghost)

	# aniamted the new ghost (drop -> wait -> fade)
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(
		ghost,
		Constants.Prop.GLOBAL_POSITION_Y,
		ghost.global_position.y + shift_amount,
		drop_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		ghost,
		Constants.Prop.MODULATE,
		ghost_target_color,
	drop_duration)
	
	tween.set_parallel(false)
	tween.tween_interval(wait_duration)
	
	tween.tween_property(ghost, Constants.Prop.MODULATE_A, 0.0, fade_duration)
	
	# Cleanup
	tween.chain().tween_callback(func():
		ghosts_list.erase(ghost)
		ghost.queue_free()
	)

## Set export vars

func _update_desc() -> void:
	if _desc_label:
		_desc_label.text = "[b]" + description_text + "[/b]"

func _update_gradient_color_modulate() -> void:
	if panel_gradient:
		panel_gradient.self_modulate = gradient_color_modulate

func _update_font_size() -> void:
	if _text_label:
		UIUtils.rr_label_set_font_size(_text_label, font_size)


func _update_margins() -> void:
	if margin_inside_panel:
		UIUtils.margin_container_set_margins(margin_inside_panel, margin_h, margin_h, margin_v, margin_v)
