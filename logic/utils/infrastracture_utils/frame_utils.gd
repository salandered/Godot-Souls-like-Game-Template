class_name FrameUtils
extends RefCounted


## STATIC GETTERS
# region

static func ifr() -> int:
	return Engine.get_process_frames()


static func sfr() -> String:
	return str(Engine.get_process_frames())


static func is_nth_frame(interval: int) -> bool:
	if interval <= 1: return true
	return ifr() % interval == 0


static func is_nth_physics_frame(interval: int) -> bool:
	if interval <= 1: return true
	return Engine.get_physics_frames() % interval == 0

# endregion


## ASYNC WAIT
# region

## ❌ Do not use in _init() or before adding node to tree

static func wait_physics_frames(for_whom: Node, count: int) -> void:
	if not for_whom: return
	if not for_whom.get_tree(): return
	for i in count:
		await for_whom.get_tree().physics_frame


static func wait_process_frames(for_whom: Node, count: int) -> void:
	if not for_whom: return
	if not for_whom.get_tree(): return
	for i in count:
		await for_whom.get_tree().process_frame


static func wait_one_process_frame(for_whom: Node) -> void:
	if not for_whom: return
	await wait_process_frames(for_whom, 1)


static func wait_one_physics_frame(for_whom: Node) -> void:
	if not for_whom: return
	await wait_physics_frames(for_whom, 1)

# endregion
