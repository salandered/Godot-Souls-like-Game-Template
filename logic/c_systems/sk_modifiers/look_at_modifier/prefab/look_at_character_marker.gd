extends Marker3D
class_name LookAtCharacterMarker


var active: bool = true


func _ready() -> void:
	add_to_group(Groups.Marker.LOOK_AT)
