extends CSGBox3D


@onready var sub_viewport: SubViewport = %SubViewport
@onready var label: Label = %Label

func set_label_text(content: String) -> void:
	label.text = content
