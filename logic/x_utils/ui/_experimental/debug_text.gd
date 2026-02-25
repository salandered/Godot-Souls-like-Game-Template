class_name DebugText
extends Node


## Spawns a floating 3D text label
static func spawn(
	parent: Node,
	location: Vector3,
	text: String,
	duration: float = 1.5,
	color: Color = Color.WHITE,
	move_speed: float = 1.5
) -> void:
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true # through walls
	label.modulate = color
	
	label.font_size = 38 # high res base font, scaled down by pixel_size
	label.outline_size = 0
	label.pixel_size = 0.0025 # adjust for sharpness
	

	if parent:
		parent.add_child(label)
		label.global_position = location
		
		var tween = label.create_tween()
		tween.set_parallel(true)
		
		var end_y = label.position.y + (move_speed * duration)

		tween.tween_property(label, "position:y", end_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		
		var fade_time = duration * 0.2
		var visible_time = duration - fade_time
		tween.tween_property(label, "modulate:a", 0.0, fade_time).set_delay(visible_time).set_ease(Tween.EASE_IN)

		tween.chain().tween_callback(label.queue_free)
