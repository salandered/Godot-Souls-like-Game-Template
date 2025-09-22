extends CSGBox3D

@export var label: String
@onready var targetable_aspect: Targetable_ = $TargetableAspect


func _ready():
	if not label:
		label = str(get_path())
	targetable_aspect.label = label
