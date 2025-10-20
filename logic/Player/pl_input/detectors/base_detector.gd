extends RefCounted
class_name BaseDetector


## Common Trivia
# Player Input Perception Thresholds (in seconds):
# 0.0 - 0.1 (0 - 6 fr): Instant. For core mechanics like jumping or shooting.
# 0.1 - 0.25 (6 - 8 fr ): Noticeable but Responsive. Good for double-taps. Industry standard is often ~0.2.
# 0.25 - 0.5 (8 - 30 fr): Deliberate Delay. Feels "heavy," used for charged attacks, consuming items.
# > 0.5: Sluggish


static func _current_time() -> float:
	return Time.get_ticks_msec() / 1000.0


static func _just_pressed_and_pressed(key_1: KeyPress, key_2: KeyPress) -> bool:
	return key_1.is_just_pressed and key_2.is_pressed

static func _just_pressed_and_not_pressed(key_1: KeyPress, key_2: KeyPress) -> bool:
	return key_1.is_just_pressed and not key_2.is_pressed
