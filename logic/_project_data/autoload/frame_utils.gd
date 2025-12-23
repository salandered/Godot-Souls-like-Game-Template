extends Node


## autoload FrameUtils


## ASYNC WAIT
# region

## ❌ Unsafe: in _init() or before adding node to tree

func wait_physics_frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


func wait_process_frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func wait_one_process_frame() -> void:
	await wait_process_frames(1)

func wait_one_physics_frame() -> void:
	await wait_physics_frames(1)


func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout

# endregion
