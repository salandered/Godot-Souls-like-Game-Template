# BoneMasks.gd
# A helper class for generating bone mask arrays (PackedInt32Array)
# based on the 53-bone skeleton structure.
class_name BoneMasks

static func _range(start: int, end_exclusive: int) -> PackedInt32Array:
	var arr := PackedInt32Array()
	if end_exclusive <= start:
		return arr
		
	arr.resize(end_exclusive - start)
	for i in range(start, end_exclusive):
		arr[i - start] = i
	return arr

# --- Full Body (Bones 0-52) ---
static func get_full_body_with_root() -> PackedInt32Array:
	return _range(0, 53) # All 53 bones (Root to LeftToes)

static func get_full_body_no_root() -> PackedInt32Array:
	return _range(1, 53) # Bones 1-52

# --- Torso & Head (Bones 1-6) ---
static func get_head_and_neck() -> PackedInt32Array:
	return [5, 6] # Neck(5), Head(6)

static func get_spine_chain() -> PackedInt32Array:
	return _range(2, 7) # Spine(2) to Head(6)

static func get_spine_chain_no_head_neck() -> PackedInt32Array:
	return _range(2, 5) # Spine(2) to 4


static func get_torso() -> PackedInt32Array:
	return _range(1, 5) # Hips(1) to UpperChest(4)

# --- Right Arm (Bones 7-25) ---
static func get_right_arm_full() -> PackedInt32Array:
	return _range(7, 26) # RightShoulder(7) to RightLittleDistal(25)

static func get_right_arm_no_fingers() -> PackedInt32Array:
	return _range(7, 11) # RightShoulder(7) to RightHand(10)

static func get_right_fingers() -> PackedInt32Array:
	return _range(11, 26) # RightThumbMetacarpal(11) to RightLittleDistal(25)

# --- Left Arm (Bones 26-44) ---
static func get_left_arm_full() -> PackedInt32Array:
	return _range(26, 45) # LeftShoulder(26) to LeftLittleDistal(44)

static func get_left_arm_no_fingers() -> PackedInt32Array:
	return _range(26, 30) # LeftShoulder(26) to LeftHand(29)

static func get_left_fingers() -> PackedInt32Array:
	return _range(30, 45) # LeftThumbMetacarpal(30) to LeftLittleDistal(44)

# --- Legs (Bones 45-52) ---
static func get_right_leg_full() -> PackedInt32Array:
	return _range(45, 49) # RightUpperLeg(45) to RightToes(48)

static func get_left_leg_full() -> PackedInt32Array:
	return _range(49, 53) # LeftUpperLeg(49) to LeftToes(52)

static func get_both_legs() -> PackedInt32Array:
	return _range(45, 53) # Both legs, 45-52

# --- Combined Presets ---
static func get_upper_body(no_head_neck: bool = false) -> PackedInt32Array:
	# Spine, Head, and both full arms
	var spine_chain: PackedInt32Array
	if no_head_neck:
		spine_chain = get_spine_chain_no_head_neck()
	else:
		spine_chain = get_spine_chain()

	var right_arm := get_right_arm_full()
	var left_arm := get_left_arm_full()
	
	spine_chain.append_array(right_arm)
	spine_chain.append_array(left_arm)
	return spine_chain
	

static func get_upper_body_with_hips() -> PackedInt32Array:
	var upper_body = get_upper_body()
	var hips := PackedInt32Array([1])
	hips.append_array(upper_body)
	return hips

## Hips and both full legs
static func get_lower_body() -> PackedInt32Array:
	var hips := PackedInt32Array([1])
	var legs := get_both_legs()
	
	hips.append_array(legs)
	return hips

static func get_both_arms() -> PackedInt32Array:
	var right_arm := get_right_arm_full()
	var left_arm := get_left_arm_full()
	
	right_arm.append_array(left_arm)
	return right_arm