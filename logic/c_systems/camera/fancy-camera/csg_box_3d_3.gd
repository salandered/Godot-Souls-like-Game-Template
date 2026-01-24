extends CSGBox3D


@onready var sub_viewport: SubViewport = %SubViewport
@onready var label: Label = %Label

func set_label_text(content: String) -> void:
	label.text = content
	
	# Optional: If you set the Viewport Update Mode to 'Once' to save performance,
	# you must manually trigger an update here:
	# text_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
