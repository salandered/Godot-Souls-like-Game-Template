class_name eu
extends RefCounted


static func pause_tree_toggle(for_whom: Node) -> void:
	if not for_whom: return
	if not for_whom.get_tree(): return
	for_whom.get_tree().paused = not for_whom.get_tree().paused


static func is_editor() -> bool:
	return Engine.is_editor_hint()


static func is_release() -> bool:
	return not OS.is_debug_build()
