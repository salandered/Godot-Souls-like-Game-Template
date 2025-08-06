extends RefCounted
class_name Detection

var seen: bool = false
var heard: bool = false
var distance: float = -1.0

func _init(_seen: bool = false, _heard: bool = false, _distance: float = -1.0):
	seen = _seen
	heard = _heard
	distance = _distance


func is_seen_and_heard() -> bool:
	return seen and heard

func is_only_heard() -> bool:
	return heard and not seen

func is_only_seen() -> bool:
	return seen and not heard

func is_seen() -> bool:
	return seen

func is_heard() -> bool:
	return heard

func is_not_detected() -> bool:
	return not seen and not heard

func _to_string() -> String:
	return "Detection(seen=%s, heard=%s, distance=%.2f)" % [str(seen), str(heard), distance]