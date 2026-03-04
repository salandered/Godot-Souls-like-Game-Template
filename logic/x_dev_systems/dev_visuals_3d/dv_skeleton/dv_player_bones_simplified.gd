@tool
extends BaseDTCDependentNode3D

## TODO: should be deleted in favor of DVSkeleton
## (DVSkeleton would need some new features)

var _bone_attachments: Array[BoneAttachment3D]


func initialize() -> void:
	visible = false
	await FrameUtils.wait_process_frames(self , 4)

	SigUtils.safe_connect_pairs([
		[GlobalUIInfo.SIG_dtc_bvalue_changed, _on_SIG_dtc_bvalue_changed]
	])


	_bone_attachments = get_descendants.bone_attachments(self )
	set_enabled(false)


func _on_SIG_dtc_bvalue_changed(payload: Dictionary[StringName, Variant]):
	var _r := DTCSIGPayloadParser.safe_bget_value_by_dtc_key(
		payload,
		DTS.KeyBValueChanger.SHOW_BONES_SIMPLIFIED
		)
	if _r.err: return

	set_enabled(_r.value)


func set_enabled(value: bool):
	visible = value

	for item in _bone_attachments:
		if not item: continue
		item.set_process(value)
