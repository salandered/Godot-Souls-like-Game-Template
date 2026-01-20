extends RefCounted
class_name EDC

class _CommitData:
	var commitment: float
	var fatigue: float
	func _init(
			commitment_: float = PHEStaticConfig.DEF_COMMITMENT,
			fatigue_: float = PHEStaticConfig.DEF_FATIGUE,
		) -> void:
		self.commitment = commitment_
		self.fatigue = fatigue_


class _AData:
	var anim_id: String
	var y_offset_adjustment: float
	func _init(
			anim_id_: String,
			y_offset_adjustment_: float = PHEStaticConfig.DEFAULT_Y_OFFSET
		) -> void:
		self.anim_id = anim_id_
		self.y_offset_adjustment = y_offset_adjustment_


class BaseStData:
	var state_name: String
	var commit_data: _CommitData

	func _init(
			state_name_: String,
			commit_data_: _CommitData = null,
		) -> void:
		self.state_name = state_name_

		if not commit_data_:
			commit_data_ = _CommitData.new()
		self.commit_data = commit_data_


class _CSData extends BaseStData:
	pass


class _LStData extends BaseStData:
	var anim_data: _AData

	func _init(
			leaf_state_name_: String,
			anim_data_: _AData,
			dur_data_: _CommitData = null,
		) -> void:
		super (leaf_state_name_, dur_data_)
		
		self.anim_data = anim_data_
