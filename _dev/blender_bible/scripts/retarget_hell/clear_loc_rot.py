import bpy

__all__ = ["clear_loc_rot"]

def clear_pose_loc_rot(armature_name: str) -> None:
    armature = bpy.data.objects.get(armature_name)
    assert armature and armature.type == 'ARMATURE', f"Armature not found or invalid: {armature_name}"

    # Ensure Object Mode, make this armature active
    if bpy.context.mode != 'OBJECT':
        bpy.ops.object.mode_set(mode='OBJECT', toggle=False)
    bpy.ops.object.select_all(action='DESELECT')
    armature.select_set(True)
    bpy.context.view_layer.objects.active = armature

    # Pose Mode
    bpy.ops.object.mode_set(mode='POSE', toggle=False)

    # Select all bones, then Alt+G and Alt+R
    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.loc_clear()  # Alt+G
    bpy.ops.pose.rot_clear()  # Alt+R

    # Back to Object Mode
    bpy.ops.object.mode_set(mode='OBJECT', toggle=False)
    print(f"[clear_loc_rot] Cleared pose loc/rot on: {armature_name}")


def clear_object_loc_rot(object_name: str, clear_rotation: bool = False) -> None:
    """
    Clears the location (Alt+G) and optionally the rotation (Alt+R) 
    of a specified object in Object Mode.

    :param object_name: The name of the object to modify.
    :param clear_rotation: If True, also clears the object's rotation.
    """
    obj = bpy.data.objects.get(object_name)
    assert obj, f"Object not found: {object_name}"

    # Ensure we are in Object Mode to operate on the object's transform
    if bpy.context.mode != 'OBJECT':
        bpy.ops.object.mode_set(mode='OBJECT')

    # Deselect all and select the target object to make it active
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj

    # Clear the object's location (Alt+G)
    bpy.ops.object.location_clear(clear_delta=False)
    print(f"Cleared location for: {obj.name}")

    # Optionally, clear the object's rotation (Alt+R)
    if clear_rotation:
        bpy.ops.object.rotation_clear(clear_delta=False)
        print(f"Cleared rotation for: {obj.name}")

# --- EXAMPLE USAGE ---
# Replace "YourArmatureName" with the actual name of your armature object.

# To clear ONLY the location (Alt+G):
# clear_object_transform("YourArmatureName")

# To clear BOTH location (Alt+G) AND rotation (Alt+R):
# clear_object_transform("YourArmatureName", clear_rotation=True)