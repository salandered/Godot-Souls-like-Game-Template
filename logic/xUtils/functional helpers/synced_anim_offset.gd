extends RefCounted
class_name AnimHelpers


static func calculate_synced_anim_offset(
	source_anim_progress: float,
	source_anim_duration: float,
	source_pivot_time: float,
	target_anim_duration: float,
	target_pivot_time: float
) -> float:
	# normalized phase (0-1) relative to pivot time
	var phase_in_cycle := fmod(source_anim_progress - source_pivot_time + source_anim_duration, source_anim_duration)
	var normalized_phase := phase_in_cycle / source_anim_duration
	
	# map this phase to target animation
	var target_phase_time := normalized_phase * target_anim_duration
	
	# adjust for target's pivot time
	var target_start_offset := fmod(target_phase_time + target_pivot_time, target_anim_duration)
	
	return target_start_offset


# region: future tests
# TEST: Different durations - speed sync
# ==========================================
# Source: 2s long, pivot at 1.0s, currently at 1.5s (0.5s past pivot = 25% through cycle)
# Target: 4s long, pivot at 2.0s
# Expected: Start target at 3.0s (same 25% phase = 1.0s past pivot)

# calculate_synced_anim_offset(
# 	1.5,  # 0.5s past pivot
# 	2.0,  # source duration
# 	1.0,  # source pivot
# 	4.0,  # target duration (twice as long)
# 	2.0   # target pivot
# )
# Output: 3.0
# Logic: 0.5s past pivot in 2s cycle = 25% phase
#        25% of 4s = 1.0s
#        2.0 (pivot) + 1.0 (phase time) = 3.0


# TEST: Real-world run→sprint example
# =======================================
# Run: 1.2s duration, foot contact at 0.6s, currently at 0.9s
# Sprint: 0.9s duration, foot contact at 0.45s
# We're 0.3s past contact = 25% through run cycle

# calculate_synced_anim_offset(
# 	0.9,   # current run progress
# 	1.2,   # run duration
# 	0.6,   # run foot contact time
# 	0.9,   # sprint duration
# 	0.45   # sprint foot contact time
# )
# Output: 0.675
# Logic: 0.3s past pivot / 1.2s = 25% phase
#        25% * 0.9s = 0.225s
#        0.45 + 0.225 = 0.675s start offset
# endregion