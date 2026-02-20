@tool
class_name DVSkeleton
extends DVCSignalEnabledNode3D


## Generates a primitive representation of the skeleton.
## - fingers ignored
## - Head is Sphere.
## - Everything else gets a Box.

## Adds bone attachmnets to itself

@export var _skeleton: Skeleton3D

@export_range(1, 20, 1) var visuals_size: float = 10


var _actual_visuals_size: float = visuals_size / 100.0
var joint_radius := _actual_visuals_size * 0.5
var bone_width := _actual_visuals_size * 0.4


var _bone_attachments: Array[BoneAttachment3D]


func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		_skeleton
	]

func __hard_validation() -> bool:
	return len(_bone_attachments) > 0


func _initialise_implementation_in_game() -> void:
	_create_visuals()
	__log_("_ready", "created", len(_bone_attachments))


func set_enabled(value: bool):
	super.set_enabled(value)

	for item in _bone_attachments:
		if not item: continue
		item.set_process(value)


func _create_visuals():
	if not _skeleton: return

	for bone_idx in BoneMask.get_all_no_fingers():
		var ba := _create_bone_attachment(bone_idx)
		if ba:
			_bone_attachments.append(ba)


func _create_bone_attachment(bone_idx: int) -> BoneAttachment3D:
	if not _skeleton: return
	if bone_idx >= _skeleton.get_bone_count(): return
	

	var _bone_name := _skeleton.get_bone_name(bone_idx)
	
	var attachment := BoneAttachment3D.new()
	attachment.name = "DVBoneAtt_" + _bone_name
	
	self.add_child(attachment)
	
	attachment.set_use_external_skeleton(true)
	attachment.set_external_skeleton(attachment.get_path_to(_skeleton))
	attachment.bone_name = _bone_name # after setting external skeleton
	
	# Visuals
	var children_indices: PackedInt32Array = []
	## dont need connections between the wrist and fingers
	if bone_idx not in [BoneIdx.LEFT_HAND_29, BoneIdx.RIGHT_HAND_10]:
		children_indices = _skeleton.get_bone_children(bone_idx)
	_add_visuals_to_bone_attachement(bone_idx, attachment, children_indices)
	
	
	return attachment


func _add_visuals_to_bone_attachement(bone_idx: int, attachment: BoneAttachment3D, children_indices: PackedInt32Array):
	var color := ra.get_random_vibrant_color()
	
	var width := bone_width
	
	if bone_idx == BoneIdx.ROOT_0:
		color = Color.RED
		width = bone_width * 1.1


	# JOINT (sphere)
	var joint_mesh := MeshInstanceUtils.create_simple_sphere(
		joint_radius,
		color,
		BaseMaterial3D.SHADING_MODE_PER_PIXEL
	)
	attachment.add_child(joint_mesh)

	# BONE SEGMENTS (cylinders)
	var cylinder: MeshInstance3D

	if children_indices.is_empty():
		# leaf bone
		var leaf_vector := Vector3.ZERO
		
		if bone_idx == BoneIdx.HEAD_6:
			# head points UP relative to itself (local y)
			# approximate len is ~25cm
			leaf_vector = Vector3(0, 0.25, 0)
		else:
			leaf_vector = Vector3(0, 0.1, 0)

		cylinder = MeshInstanceUtils.create_bone_like_connector(
			Vector3.ZERO, leaf_vector, color, width
		)
		if cylinder: attachment.add_child(cylinder)
		
	else:
		# standard bone
		for child_idx: int in children_indices:
			# get child's offset in parent's space (rest pose)
			var child_rest := _skeleton.get_bone_rest(child_idx)
			var child_offset := child_rest.origin
			
			cylinder = MeshInstanceUtils.create_bone_like_connector(
				Vector3.ZERO, child_offset, color, width
			)
			if cylinder: attachment.add_child(cylinder)
