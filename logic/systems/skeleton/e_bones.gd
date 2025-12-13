@tool
extends BaseCharBones
class_name EnemyBones

@onready var general_skeleton: Skeleton3D = %GeneralSkeleton


func accept_bones():
	for child: BoneAttachment3D in get_descendants.bone_attachments(self):
		child.set_external_skeleton(general_skeleton.get_path())
