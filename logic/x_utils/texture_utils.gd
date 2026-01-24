class_name TextureUtils
extends RefCountedStaticLogger


static func randomize_button_normal_region(root_node: Node, max_offset: float = 100.0, only_visible: bool = true) -> void:
	if not root_node: return
	
	var buttons := get_descendants.buttons(root_node)
	__log_("randomize_button_normal_region", "Found buttons", buttons.size())

	for btn: Button in buttons:
		if only_visible and not btn.is_visible_in_tree():
			continue
		
		# Buttons use the "normal" stylebox override
		_apply_random_displacement_to_control(btn, "normal", max_offset)


static func randomize_shake_button_panel_region(root_node: Node, max_offset: float = 100.0, only_visible: bool = true) -> void:
	if not root_node: return
	
	# Find all Panels (including the ones inside ShakeButtons)
	var shake_buttons := get_descendants.shake_buttons(root_node)
	__log_("randomize_shake_button_panel_region", "Found shake_buttons", shake_buttons.size())

	for button in shake_buttons:
		var panel := button.get_panel()
		if not panel:
			continue
		if only_visible and not panel.is_visible_in_tree():
			continue
			
		# Panels use the "panel" stylebox override
		_apply_random_displacement_to_control(panel, "panel", max_offset)


static func _apply_random_displacement_to_control(control: Control, style_name: String, max_offset: float) -> void:
	var current_style := control.get_theme_stylebox(style_name)
	
	# Generate the randomized stylebox
	var new_style := _create_randomized_stylebox_texture(current_style, control.name, max_offset)
	
	if new_style:
		# Apply it back to the specific style override ("normal" vs "panel")
		control.add_theme_stylebox_override(style_name, new_style)


static func _create_randomized_stylebox_texture(original_style: StyleBox, debug_name: String, max_offset: float) -> StyleBoxTexture:
	# Validation
	if not original_style is StyleBoxTexture:
		return null
		
	var casted_style: StyleBoxTexture = original_style
	var tex := casted_style.texture
	if not tex:
		__log_("_create_randomized_stylebox_texture", "Skip: No texture in style", debug_name)
		return null

	# Duplication
	var new_style: StyleBoxTexture = casted_style.duplicate()
	
	var rect := new_style.region_rect
	var tex_w := tex.get_width()
	var tex_h := tex.get_height()
	
	# Handle full-texture rects
	if not rect.has_area():
		rect = Rect2(0, 0, tex_w, tex_h)
	
	# Math: Calculate Displacement
	var dx := randf_range(-max_offset, max_offset)
	# (Preserving your original Y logic: favoring top/bottom edges?)
	var dy := randf_range(-max_offset, -max_offset / 2.0) if ra.coinflip() else randf_range(max_offset / 2.0, max_offset)
	
	# Math: Clamp within bounds
	var new_x := clampf(rect.position.x + dx, 0.0, tex_w - rect.size.x)
	var new_y := clampf(rect.position.y + dy, 0.0, tex_h - rect.size.y)
	
	# Apply
	new_style.region_rect = Rect2(new_x, new_y, rect.size.x, rect.size.y)
	
	__log_("_create_randomized_stylebox_texture",
		"Applied to", debug_name,
		"Offset", Vector2(dx, dy),
		"New Rect", new_style.region_rect)
		
	return new_style


# region: __LOGS

static func pp_name() -> String:
	return "TextureUtils"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion