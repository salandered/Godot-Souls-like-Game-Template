import bpy

__all__ = ["copy_root_location_from_empty"]

# --- local test config ---
ARMATURE_NAME = "Armature.001"
BONE_NAME = "Root"
EMPTY_NAME = "Empty"


def copy_root_location_from_empty(armature_name: str, bone_name: str, empty_name: str) -> None:
    # resolve
    arm = bpy.data.objects[armature_name]
    empty = bpy.data.objects[empty_name]

    # pose mode on the armature
    bpy.ops.object.select_all(action='DESELECT')
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')

    # select only the target bone
    bpy.ops.pose.select_all(action='DESELECT')
    bone = arm.data.bones[bone_name]
    bone.select = True
    arm.data.bones.active = bone

    # add Copy Location constraint to that pose bone, targeting the Empty
    pbone = arm.pose.bones[bone_name]
    con = pbone.constraints.new(type='COPY_LOCATION')
    con.target = empty
    # defaults: WORLD→WORLD, location only (rot/scale unaffected)

if __name__ == "__main__":
    copy_root_location_from_empty(ARMATURE_NAME, BONE_NAME, EMPTY_NAME)
