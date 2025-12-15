extends RefCounted
class_name AnimMarker

## DOCS
# Animation Markers are persistent - they're part of the Animation resource structure.
# 
# For native Godot animations (.res): Markers save automatically.
# 
# For imported animations (GLB/FBX): Enable "Save to File" in Advanced Import Settings
# to create a separate .res file, otherwise markers will be lost on reimport! WARNING
# 
# Note: Markers are NOT "custom tracks" - they're timeline metadata.
# The "Keep Custom Tracks" setting only applies to actual anim tracks.


var time: float
var marker_name: String


func _init(time_: float, marker_name_: String) -> void:
	time = time_
	marker_name = marker_name_


func _to_string() -> String:
	return pp.s(pp.in_q(marker_name), time)