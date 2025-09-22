import bpy

__all__ = ["bake_root_bone"]

def _view3d_override(active_obj):
    win = bpy.context.window
    scr = win.screen
    area = next((a for a in scr.areas if a.type == 'VIEW_3D'), None)
    region = next((r for r in (area.regions if area else [] ) if r.type == 'WINDOW'), None)
    return {
        "window": win,
        "screen": scr,
        "area": area,
        "region": region,
        "scene": bpy.context.scene,
        "view_layer": bpy.context.view_layer,
        "active_object": active_obj,
        "object": active_obj,
    }

def bake_root_bone(armature_name: str, bone_name: str, frame_start=None, frame_end=None, clear_constraints: bool = True) -> None:
    arm = bpy.data.objects[armature_name]
    scene = bpy.context.scene
    fs = scene.frame_start if frame_start is None else frame_start
    fe = scene.frame_end   if frame_end   is None else frame_end

    # make active and enter POSE mode (under a 3D View override)
    ov = _view3d_override(arm)
    with bpy.context.temp_override(**ov):
        bpy.context.view_layer.objects.active = arm
        bpy.ops.object.mode_set(mode='POSE')

    # select only the target bone using the data API (no operators)
    for b in arm.data.bones:
        b.select = False
    b = arm.data.bones[bone_name]
    b.select = True
    arm.data.bones.active = b

    # bake (still under 3D View override)
    with bpy.context.temp_override(**ov):
        bpy.ops.nla.bake(
            frame_start=fs,
            frame_end=fe,
            step=1,
            only_selected=True,
            visual_keying=True,
            clear_constraints=clear_constraints,
            use_current_action=True,
            bake_types={'POSE'}
        )

if __name__ == "__main__":
    # quick standalone test (edit names if needed)
    ARMATURE_NAME = "Armature"
    BONE_NAME = "Root"
    bake_root_bone(ARMATURE_NAME, BONE_NAME)
