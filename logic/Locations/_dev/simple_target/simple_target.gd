extends CSGBox3D

@export var label: String
@onready var targetable_aspect: CameraTarget = $TargetableAspect


func _ready() -> void:
	if not label:
		label = str(get_path())
	targetable_aspect.label = label
