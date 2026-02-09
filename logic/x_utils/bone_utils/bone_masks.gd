# A helper class for generating bone mask arrays
class_name BoneMask

## Docs
## Initially used PackedInt32Array but it's not worth it. 
##   - array lengths are ~50 max
##   - usually we use this on set up
##   - client code uses Array[int]
## Consider PackedInt32Array only in case of perf problems


# region Spine Head etc (Bones 1-6)

static func get_head_and_neck() -> Array[int]:
	return [BoneIdx.NECK, BoneIdx.HEAD]


static func get_spine_chain() -> Array[int]:
	return _range(2, 7) # Spine to Head 6


static func get_spine_chain_no_head_neck() -> Array[int]:
	return _range(2, BoneIdx.NECK) # Spine to 4


static func get_torso() -> Array[int]:
	return _range(BoneIdx.HIPS, BoneIdx.NECK) # Hips to UpperChest 4


static func get_hips() -> Array[int]:
	return [BoneIdx.HIPS]

# endregion


# region Arms 

static func get_right_arm_full() -> Array[int]:
	return _range(7, 26) # RightShoulder(7) to RightLittleDistal(25)


static func get_right_arm_no_fingers() -> Array[int]:
	return _range(7, 11) # RightShoulder(7) to RightHand(10)


static func get_right_fingers() -> Array[int]:
	return _range(11, 26) # RightThumbMetacarpal(11) to RightLittleDistal(25)


static func get_left_arm_full() -> Array[int]:
	return _range(26, 45) # LeftShoulder(26) to LeftLittleDistal(44)

static func get_left_arm_no_fingers() -> Array[int]:
	return _range(26, 30) # LeftShoulder(26) to LeftHand(29)

static func get_left_fingers() -> Array[int]:
	return _range(30, 45) # LeftThumbMetacarpal(30) to LeftLittleDistal(44)

# endregion


# region Legs (Bones 45-52) 

static func get_right_leg_full() -> Array[int]:
	return _range(45, 49) # RightUpperLeg(45) to RightToes(48)

static func get_left_leg_full() -> Array[int]:
	return _range(49, Constants.BONE_COUNT) # LeftUpperLeg(49) to LeftToes(52)

static func get_both_legs() -> Array[int]:
	return _range(45, Constants.BONE_COUNT) # Both legs, 45-52

# endregion


# region BODY

static func get_upper_body(no_head_neck: bool = false) -> Array[int]:
	# Spine, Head, and both full arms
	var spine_chain: Array[int]
	if no_head_neck:
		spine_chain = get_spine_chain_no_head_neck()
	else:
		spine_chain = get_spine_chain()

	var right_arm := get_right_arm_full()
	var left_arm := get_left_arm_full()
	
	spine_chain.append_array(right_arm)
	spine_chain.append_array(left_arm)
	return spine_chain
	

static func get_upper_body_with_hips() -> Array[int]:
	var upper_body := get_upper_body()
	var hips := get_hips()
	hips.append_array(upper_body)
	return hips


## Hips and both full legs
static func get_lower_body() -> Array[int]:
	var hips := get_hips()
	var legs := get_both_legs()
	
	hips.append_array(legs)
	return hips

static func get_both_arms() -> Array[int]:
	var right_arm := get_right_arm_full()
	var left_arm := get_left_arm_full()
	
	right_arm.append_array(left_arm)
	return right_arm


static func get_full_body_with_root() -> Array[int]:
	return _range(BoneIdx.ROOT, Constants.BONE_COUNT) # All 53 bones


static func get_full_body_no_root() -> Array[int]:
	return _range(BoneIdx.HIPS, Constants.BONE_COUNT) # Bones 1-52


# endregion

static func _range(start: int, end_exclusive: int) -> Array[int]:
	var arr: Array[int] = []
	for i in range(start, end_exclusive):
		arr.append(i)
	return arr


##

# region Right Arm + Torso Variants (No Hips)

## Best for: Shooting/Aiming while running.
## Includes Right Arm + Spine, Chest, UpperChest (2, 3, 4).
## Allows the character to twist their back to aim, but keeps hips/legs for running.
static func get_right_arm_with_spine() -> Array[int]:
	var arm := get_right_arm_full()
	# Reuse existing spine logic (2-5 excludes hips 1 and neck 5)
	var spine := get_spine_chain_no_head_neck()
	
	spine.append_array(arm)
	return spine


## Best for: Isolated actions like waving, holding a torch, or carrying an object.
## Includes Right Arm + UpperChest (4) only.
## Stabilizes the shoulder but leaves the lower spine stiff/independent.
static func get_right_arm_with_upper_chest() -> Array[int]:
	var arm := get_right_arm_full()
	# 4 is UpperChest
	var upper_chest: Array[int] = [4]
	
	upper_chest.append_array(arm)
	return upper_chest


## Best for: Looking and pointing/shooting.
## Includes Right Arm + Spine chain + Head (2-6).
## The character looks where they are aiming.
static func get_right_arm_with_spine_and_head() -> Array[int]:
	var arm := get_right_arm_full()
	var spine_head := get_spine_chain() # 2 to 6
	
	spine_head.append_array(arm)
	return spine_head


## Best for: complex upper body actions involving the left shoulder stability
## Includes Right Arm + Spine (2-4) + Left Shoulder (26)
## Prevents the left shoulder from looking broken if the spine twists significantly.
static func get_right_arm_with_spine_and_left_shoulder() -> Array[int]:
	var mask := get_right_arm_with_spine()
	mask.append(26) # LeftShoulder
	return mask

# endregion


static func get_all_no_fingers() -> Array[int]:
	var indices: Array[int] = []
	# Root(0) to RightHand(10) inclusive
	indices.append_array(_range(0, 11))
	# LeftShoulder(26) to LeftHand(29) inclusive
	indices.append_array(_range(26, 30))
	# RightUpperLeg(45) to End
	indices.append_array(_range(45, Constants.BONE_COUNT))
	return indices