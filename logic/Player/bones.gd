@tool
@icon("uid://b5xt1a7igr101")
extends Node3D
class_name PlayerBones

@onready var right_wrist_marker: Marker3D = $RightWrist/Marker3D
@onready var general_skeleton: Skeleton3D = %GeneralSkeleton
@onready var right_wrist: BoneAttachment3D = $RightWrist

#var specific_weapon: BaseWeapon

#func _ready():
	#specific_weapon = get_descendants.base_weapons_only_one(right_wrist)

# TODO: flying head without eyes
func accept_bones():
	for child: BoneAttachment3D in get_descendants.bone_attachments(self):
		child.set_external_skeleton(general_skeleton.get_path())
