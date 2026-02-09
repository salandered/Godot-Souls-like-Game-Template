extends Node3D

## TODO: should be deleted in favor of DVSkeleton
## (DVSkeleton would need some new features)

var _bone_attachments: Array[BoneAttachment3D]


func _ready() -> void:
	visible = false
	await FrameUtils.wait_process_frames(4)

	SigUtils.safe_connect_pairs([
		[GlobalUIInfo.SIG_dvc_bvalue_changed, _on_SIG_dvc_bvalue_changed]
	])


	_bone_attachments = get_descendants.bone_attachments(self )
	set_enabled(false)


func _on_SIG_dvc_bvalue_changed(payload: Dictionary[String, Variant]):
	var _r := DVCSIGPayloadParser.safe_bget_value_by_dvc_key(
		payload,
		DVS.KeyBValueChanger.SHOW_BONES_SIMPLIFIED
		)
	if _r.err: return

	set_enabled(_r.value)


func set_enabled(value: bool):
	visible = value

	for item in _bone_attachments:
		if not item: continue
		item.set_process(value)
