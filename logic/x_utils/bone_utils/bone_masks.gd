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
	return [BoneIdx.NECK_5, BoneIdx.HEAD_6]


static func get_spine_chain() -> Array[int]:
	return _range(BoneIdx.SPINE_2, BoneIdx.RIGHT_SHOULDER_7) # Spine to Head 6


static func get_spine_chain_no_head_neck() -> Array[int]:
	return _range(BoneIdx.SPINE_2, BoneIdx.NECK_5) # Spine to 4


static func get_torso() -> Array[int]:
	return _range(BoneIdx.HIPS_1, BoneIdx.NECK_5) # Hips to UpperChest 4


static func get_hips() -> Array[int]:
	return [BoneIdx.HIPS_1]

# endregion


# region Arms 

static func get_arm_full(side: StringName) -> Array[int]:
	if side == Side.RIGHT:
		return _range(BoneIdx.RIGHT_SHOULDER_7, BoneIdx.LEFT_SHOULDER_26) # to RightLittleDistal(25)
	else:
		return _range(BoneIdx.LEFT_SHOULDER_26, 45) # to LeftLittleDistal(44)


static func get_arm_no_fingers(side: StringName) -> Array[int]:
	if side == Side.RIGHT:
		return _range(BoneIdx.RIGHT_SHOULDER_7, 11) # to RightHand(10)
	else:
		return _range(BoneIdx.LEFT_SHOULDER_26, 30) # to LeftHand(29)


static func get_fingers(side: StringName) -> Array[int]:
	if side == Side.RIGHT:
		return _range(11, BoneIdx.LEFT_SHOULDER_26) # to RightLittleDistal(25)
	else:
		return _range(30, 45) # to LeftLittleDistal(44)


static func get_both_arms() -> Array[int]:
	var r := get_arm_full(Side.RIGHT)
	var l := get_arm_full(Side.LEFT)
	
	r.append_array(l)
	return r

# endregion


# region Legs (Bones 45-52) 

static func get_leg_full(side: StringName) -> Array[int]:
	if side == Side.RIGHT:
		return _range(45, 49) # RightUpperLeg(45) to RightToes(48)
	else:
		return _range(49, Constants.BONE_COUNT_53) # LeftUpperLeg(49) to LeftToes(52)


static func get_both_legs() -> Array[int]:
	var r := get_leg_full(Side.RIGHT)
	var l := get_leg_full(Side.LEFT)
	
	r.append_array(l)
	return r

# endregion


# region BODY

static func get_upper_body(no_head_neck: bool = false) -> Array[int]:
	# Spine, Head, and both full arms
	var spine_chain: Array[int]
	if no_head_neck:
		spine_chain = get_spine_chain_no_head_neck()
	else:
		spine_chain = get_spine_chain()

	spine_chain.append_array(get_both_arms())
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


static func get_full_body_with_root() -> Array[int]:
	return _range(BoneIdx.ROOT_0, Constants.BONE_COUNT_53) # All 53 bones


static func get_full_body_no_root() -> Array[int]:
	return _range(BoneIdx.HIPS_1, Constants.BONE_COUNT_53) # Bones 1-52


# endregion

static func _range(start: int, end_exclusive: int) -> Array[int]:
	var arr: Array[int] = []
	for i in range(start, end_exclusive):
		arr.append(i)
	return arr


##

# region Arm + Torso Variants (No Hips)

## may be: Shooting/Aiming while running.
## Right Arm + Spine, Chest, UpperChest (2, 3, 4).
## allows the character to twist their back to aim
static func get_arm_with_spine(side: StringName) -> Array[int]:
	var arm := get_arm_full(side)
	var spine := get_spine_chain_no_head_neck()
	spine.append_array(arm)
	return spine


## isolated actions like waving, holding a torch, or carrying an object.
## if RIGHT Includes Right Arm + UpperChest (4) only.
## stabilizes the shoulder but leaves the lower spine stiff/independent.
static func get_arm_with_upper_chest(side: StringName) -> Array[int]:
	var arm := get_arm_full(side)
	arm.append(BoneIdx.UPPER_CHEST_4)
	return arm


## Looking and pointing/shooting.
## if RIGHT: Includes Right Arm + Spine chain + Head (2-6).
## The character looks where they are aiming.
static func get_arm_with_spine_and_head(side: StringName) -> Array[int]:
	var arm := get_arm_full(side)
	var spine_head := get_spine_chain() # 2 to 6
	
	spine_head.append_array(arm)
	return spine_head


## complex upper body actions involving the left shoulder stability
## if RIGHT Includes Right Arm + Spine (2-4) + Left Shoulder (26)
## Prevents the left shoulder from looking broken if the spine twists significantly.
static func get_arm_with_spine_and_opposite_shoulder(side: StringName) -> Array[int]:
	var mask := get_arm_with_spine(side)
	if side == Side.RIGHT:
		mask.append(BoneIdx.LEFT_SHOULDER_26)
	else:
		mask.append(BoneIdx.RIGHT_SHOULDER_7)
	return mask


# endregion


static func get_all_no_fingers() -> Array[int]:
	var indices: Array[int] = []
	indices.append_array(_range(BoneIdx.ROOT_0, 11)) # to RightHand(10)
	indices.append_array(_range(BoneIdx.LEFT_SHOULDER_26, 30)) # to LeftHand(29)
	# RightUpperLeg(45) to End
	indices.append_array(_range(45, Constants.BONE_COUNT_53))
	return indices