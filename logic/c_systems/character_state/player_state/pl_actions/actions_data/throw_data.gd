class_name ThrowData
extends RefCounted


## STRUCTURES

enum ThrowDir {
	LEFT,
	RIGHT,
	BACK
}


class Pack:
	var anim_id: String
	var peak_speed: float
	var end_speed: float
	var extra_start_speed: float
	var direction: ThrowDir
	func _init(anim_id_: String, peak_speed_: float, end_speed_: float, extra_start_speed_: float, direction_: ThrowDir) -> void:
		self.anim_id = anim_id_
		self.peak_speed = peak_speed_
		self.end_speed = end_speed_
		self.extra_start_speed = extra_start_speed_
		self.direction = direction_


class DirCollection:
	var _dict: Dictionary[ThrowDir, Pack] = {}

	func _init(l_pack: Pack, r_pack: Pack, b_pack: Pack) -> void:
		_dict[ThrowDir.LEFT] = l_pack
		_dict[ThrowDir.RIGHT] = r_pack
		_dict[ThrowDir.BACK] = b_pack

	func get_pack_by_throw_dir(throw_dir: ThrowDir) -> Pack:
		var _r: Pack = DictUtils.safe_get_dict_key(_dict, throw_dir, ThrowData.default_pack)
		return _r


static func attack_dir_to_throw_dir(attack_dir: AttackDirection.Dir) -> ThrowDir:
	match attack_dir:
		AttackDirection.Dir.LEFT:
			return ThrowDir.RIGHT
		AttackDirection.Dir.RIGHT:
			return ThrowDir.LEFT
		_:
			return ThrowDir.BACK


static func throw_dir_mirror(throw_dir: ThrowDir) -> ThrowDir:
	match throw_dir:
		ThrowDir.LEFT:
			return ThrowDir.RIGHT
		ThrowDir.RIGHT:
			return ThrowDir.LEFT
		ThrowDir.BACK:
			return ThrowDir.RIGHT ## somehow
		_:
			return DEF_THROW_DIR

## PRIVATE DATA

static var _ANIM_L := A.fall_stand_up.thrown_l_rm
static var _ANIM_R := A.fall_stand_up.thrown_r_rm
static var _ANIM_L_LOW := A.fall_stand_up.thrown_l_small_rm
static var _ANIM_R_LOW := A.fall_stand_up.thrown_r_small_rm
static var _ANIM_L_COOL := A.fall_stand_up.cool_thrown_l_rm
static var _ANIM_R_COOL := A.fall_stand_up.cool_thrown_r_rm


static var DEF_PEAK_SP: float = 8.5
static var DEF_END_SP: float = 0.0
static var DEF_EXTRA_START_SP: float = 0.0

static var left_throw_pack := Pack.new(_ANIM_L, DEF_PEAK_SP + 2.0, DEF_END_SP, DEF_EXTRA_START_SP + 2.0, ThrowDir.LEFT)
static var right_throw_pack := Pack.new(_ANIM_R, DEF_PEAK_SP + 2.0, DEF_END_SP, DEF_EXTRA_START_SP + 2.0, ThrowDir.RIGHT)
static var back_throw_pack := Pack.new(_ANIM_R, DEF_PEAK_SP + 2.0, DEF_END_SP, DEF_EXTRA_START_SP + 2.0, ThrowDir.BACK) # uses right anim
static var left_low_throw_pack := Pack.new(_ANIM_L_LOW, DEF_PEAK_SP, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.5, ThrowDir.LEFT)
static var right_low_throw_pack := Pack.new(_ANIM_R_LOW, DEF_PEAK_SP, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.5, ThrowDir.RIGHT)
static var back_low_throw_pack := Pack.new(_ANIM_R_LOW, DEF_PEAK_SP, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.5, ThrowDir.BACK)
static var left_cool_throw_pack := Pack.new(_ANIM_L_COOL, DEF_PEAK_SP - 2.0, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.1, ThrowDir.LEFT)
static var right_cool_throw_pack := Pack.new(_ANIM_R_COOL, DEF_PEAK_SP - 2.0, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.1, ThrowDir.RIGHT)
static var back_cool_throw_pack := Pack.new(_ANIM_R_COOL, DEF_PEAK_SP - 2.0, DEF_END_SP + 0.2, DEF_EXTRA_START_SP + 0.1, ThrowDir.BACK)

static var default_pack = right_throw_pack

## PUBLIC DATA

static var DEF_THROW_DIR := ThrowDir.RIGHT
static var usual_dir_col := DirCollection.new(left_throw_pack, right_throw_pack, back_throw_pack)
static var low_dir_col := DirCollection.new(left_low_throw_pack, right_low_throw_pack, back_low_throw_pack)
static var cool_dir_col := DirCollection.new(left_cool_throw_pack, right_cool_throw_pack, back_cool_throw_pack)