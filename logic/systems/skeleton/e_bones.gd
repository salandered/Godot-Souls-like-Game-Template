class_name EnemyBones
extends BaseCharBones

@export var general_skeleton: Skeleton3D


func accept_bones():
	for child: BoneAttachment3D in get_descendants.bone_attachments(self):
		child.set_external_skeleton(general_skeleton.get_path())
