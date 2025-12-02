extends Node3D

class_name Skeleton1607Wrapper

@onready var general_skeleton: Skeleton3D = %GeneralSkeleton
@onready var skeleton_mesh_004: MeshInstance3D = $Armature_009/GeneralSkeleton/SkeletonMesh_004


func get_general_skeleton() -> Skeleton3D:
	return general_skeleton

func get_skeleton_mesh() -> MeshInstance3D:
	return skeleton_mesh_004
