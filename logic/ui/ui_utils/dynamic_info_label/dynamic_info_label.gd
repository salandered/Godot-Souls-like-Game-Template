@tool
class_name DynamicInfoLabel
extends ControlSystem


const DEF_WAIT_SEC := 2.5

@export_group("Text Config")
@export var title_text: String = "State":
	set(value):
		title_text = value
		_update_title()
		
## NOTE: used in editor for preview only
@export var in_editor_label_text: String = "something":
	set(value):
		in_editor_label_text = value
		_update_in_editor_label_text()

@export var additional_title_text: String = "":
	set(value):
		additional_title_text = value
		_update_title()


@export var title_font_size: int = 20:
	set(value):
		title_font_size = value
		_update_font_size()


@export var font_size: int = 24:
	set(value):
		font_size = value
		_update_font_size()


@export_group("Color Settings")
@export var gradient_color_modulate: Color = Color.WHITE:
	set(value):
		gradient_color_modulate = value
		_update_gradient_color_modulate()
# 481317

#@export_group("Margins inside the panel")
#@export var margin_h: int = 15:
	#set(value):
		#margin_h = value
		#_update_margins()
#
#@export var margin_v: int = 10:
	#set(value):
		#margin_v = value
		#_update_margins()


@export_group("Prev text animation")
@export var auto_drop_height: bool = true
## ignored if auto_drop_height true
@export var drop_distance: float = 20.0
@export var drop_buffer: float = 2.0
@export var drop_duration: float = 0.3
var wait_duration: float = DEF_WAIT_SEC
@export var fade_duration: float = 0.5
@export var ghost_target_color: Color = Color(0.6, 0.6, 0.6, 1.0) # Dim gray


@onready var margin_inside_panel: MarginContainer = %MarginInsidePanel
@onready var _title_label: RichTextLabel = %Title
@onready var _title_additional_label: RichTextLabel = %TitleAdditional
@onready var _text_label: RichTextLabel = %Text
@onready var panel_gradient: PanelContainer = %PanelGradient
@onready var __margin_2: MarginContainer = %__margin2


var _active_ghosts: Array[RichTextLabel] = []
var initial_font_size: int


func _ready() -> void:
	initial_font_size = font_size
	_update_title()
	_update_in_editor_label_text()
	_update_font_size()
	_update_gradient_color_modulate()
	#_update_margins()
	
	if additional_title_text == "":
		__margin_2.visible = false
	else:
		__margin_2.visible = true
		
	if not Engine.is_editor_hint():
		reset_text()

		SigUtils.safe_connect(GlobalUIInfo.SIG_dvc_fvalue_changed, _on_SIG_dvc_fvalue_changed)


func reset_text() -> void:
	set_label_text("", null)
	_active_ghosts = []


func set_label_text(new_text: String, dynamic_label_config: DynamicLabelConfig = null) -> void:
	_set_label_text(_active_ghosts, _text_label, new_text, dynamic_label_config)


func _set_label_text(
	ghosts_list: Array[RichTextLabel],
	label: RichTextLabel,
	new_text: String,
	dynamic_label_config: DynamicLabelConfig,
	ignore_font_size_adjustment: bool = false
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

	if not ignore_font_size_adjustment:
		_adjust_font_size(label, new_text)

	if dynamic_label_config.in_bold:
		new_text = "[b]" + new_text + "[/b]"

	if dynamic_label_config.in_italics:
		new_text = "[i]" + new_text + "[/i]"
	

	label.text = new_text


## calculates font size to fit text within a specific width
func _get_shrunk_font_size(text: String, max_width: float, base_size: int) -> int:
	var font: Font = get_theme_font("normal_font")
	
	# width of text at the base font size
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, base_size)
	
	# scale down if text is wider than the container
	if text_size.x > max_width:
		var ratio: float = max_width / text_size.x
		return int(base_size * ratio)
	
	return base_size


func _adjust_font_size(label: RichTextLabel, new_text: String):
	# kinda works
	var target_width: float = label.size.x
	
	
	var new_size: int = _get_shrunk_font_size(new_text, target_width, initial_font_size)
	
	if label:
		ControlUtils.rr_label_set_font_size(label, new_size)


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
	ghost.size = label.size
	ghost.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	ghost.global_position = label.global_position


	if dynamic_label_config.adjust_prev_font_size:
		ControlUtils.rr_label_mult_font_size(ghost, 0.9)

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
			PropC.GLOBAL_POSITION_Y,
			current_y + shift_amount, drop_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	ghosts_list.append(ghost)

	# aniamted the new ghost (drop -> wait -> fade)
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(
		ghost,
		PropC.GLOBAL_POSITION_Y,
		ghost.global_position.y + shift_amount,
		drop_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		ghost,
		PropC.MODULATE,
		ghost_target_color,
	drop_duration)
	
	tween.set_parallel(false)
	tween.tween_interval(wait_duration)
	
	tween.tween_property(ghost, PropC.MODULATE_A, 0.0, fade_duration)
	
	# Cleanup
	tween.chain().tween_callback(func():
		ghosts_list.erase(ghost)
		ghost.queue_free()
	)

## Set export vars

func _update_title() -> void:
	if _title_label:
		_title_label.text = "[b]" + title_text + "[/b]"
	if _title_additional_label:
		_title_additional_label.text = "[b]" + additional_title_text + "[/b]"
	

func _update_in_editor_label_text() -> void:
	if Engine.is_editor_hint():
		set_label_text(in_editor_label_text)

		
func _update_gradient_color_modulate() -> void:
	if panel_gradient:
		panel_gradient.self_modulate = gradient_color_modulate

func _update_font_size() -> void:
	if _text_label:
		ControlUtils.rr_label_set_font_size(_text_label, font_size)
	if _title_label:
		ControlUtils.rr_label_set_font_size(_title_label, title_font_size)
	if _title_additional_label:
		ControlUtils.rr_label_set_font_size(_title_additional_label, title_font_size - 1)
		

#func _update_margins() -> void:
	#if margin_inside_panel:
		#ControlUtils.margin_container_set_margins(margin_inside_panel, margin_h, margin_h, margin_v, margin_v)


func _on_SIG_dvc_fvalue_changed(payload: Dictionary[String, Variant]):
	var _r := DVCSIGPayloadParser.safe_fget_value_by_dvc_key(
		payload,
		DVS.KeyFValueChanger.GHOST_DUR_SEC
		)
	if _r.err: return

	__log_("wait_duration updated with", _r.value, "from", wait_duration)
	wait_duration = _r.value
