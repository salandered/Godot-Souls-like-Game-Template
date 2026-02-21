class_name CursorTools
extends Node


@export_category("Cursor")
@export var cursor_texture: Texture2D
@export var cursor_hotspot: Vector2 = Vector2(0, 0) # Top-left by default


@export_category("Accessibility")
@export var bigger_size_on_lanch: bool = false
@export var trail_on_lanch: bool = false

@export_category("Trail")
@export var trail_color: Color = Color.GOLD
@export var trail_remove_rate: float = 0.02


var _time_since_last_remove: float = 0.0


var _trail_line: Line2D
var _is_large: bool = false
var _default_hotspot: Vector2
var _trail_enabled: bool = false


func _ready() -> void:
	if cursor_texture:
		# Input.CURSOR_ARROW is the default pointer shape
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, cursor_hotspot)
	
	_default_hotspot = cursor_hotspot
	
	_setup_trail()

	if bigger_size_on_lanch:
		_toggle_size()
	if trail_on_lanch:
		_toggle_trail()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_KP_2:
			_toggle_trail()
		
		if event.keycode == KEY_KP_1:
			_toggle_size()


func _process(delta: float) -> void:
	if _trail_enabled and _trail_line and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		var mouse_pos := get_viewport().get_mouse_position()
		
		var should_add := true
		if _trail_line.get_point_count() > 0:
			var last_point := _trail_line.get_point_position(_trail_line.get_point_count() - 1)
			if last_point.distance_squared_to(mouse_pos) < 10.0:
				should_add = false
				_trail_line.set_point_position(_trail_line.get_point_count() - 1, mouse_pos)
		
		if should_add:
			_trail_line.add_point(mouse_pos)
		
		_time_since_last_remove += delta
		if _time_since_last_remove > trail_remove_rate:
			_time_since_last_remove = 0.0
			if _trail_line.get_point_count() > 0:
				_trail_line.remove_point(0)
				
		if _trail_line.get_point_count() > 100:
			_trail_line.remove_point(0)
			
	elif _trail_line and _trail_line.get_point_count() > 0:
		_trail_line.clear_points()


func _setup_trail() -> void:
	_trail_line = Line2D.new()
	_trail_line.width = 8.0 # Doubled thickness
	_trail_line.default_color = trail_color
	
	var gradient := Gradient.new()
	gradient.set_color(0, Color(trail_color, 0.0)) # Tail (transparent)
	gradient.set_color(1, trail_color) # Head (solid)
	_trail_line.gradient = gradient
	
	_trail_line.top_level = true
	_trail_line.visible = false
	add_child(_trail_line)


func _toggle_trail() -> void:
	_trail_enabled = not _trail_enabled
	_trail_line.visible = _trail_enabled
	_trail_line.clear_points()


func _toggle_size() -> void:
	if not cursor_texture: return
	
	_is_large = not _is_large
	var final_tex: Texture2D = cursor_texture
	var final_hotspot: Vector2 = _default_hotspot

	if _is_large:
		var img: Image = cursor_texture.get_image()
		# Scale up 2x
		img.resize(img.get_width() * 2, img.get_height() * 2, Image.INTERPOLATE_NEAREST)
		final_tex = ImageTexture.create_from_image(img)
		final_hotspot = _default_hotspot * 2
	
	Input.set_custom_mouse_cursor(final_tex, Input.CURSOR_ARROW, final_hotspot)
