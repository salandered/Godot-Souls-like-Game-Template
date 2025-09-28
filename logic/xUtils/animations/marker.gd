extends RefCounted
class_name M


class MarkerName:
	const START = "start"
	const END = "end"

	# specific
	const JUMP_LAUNCH = "jump_launch"


class Marker extends RefCounted:
	var time: float
	var marker_name: String

	func _init(time_: float = -1, marker_name_: String = "") -> void:
		time = time_
		marker_name = marker_name_