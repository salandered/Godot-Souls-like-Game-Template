import bpy

__all__ = ["run_retarget"]

def run_retarget(source_armature_name: str, target_armature_name: str) -> None:
    """
    Run Rokoko retarget using the add-on's current UI state ("sticky" settings).
    NOTE: U must have everything selected/configured in the UI!
    """
    print("[run_retarget] poll:", bpy.ops.rsl.retarget_animation.poll())
    res = bpy.ops.rsl.retarget_animation()
    print("[run_retarget] result:", res)  # {'FINISHED'} or {'CANCELLED'}
