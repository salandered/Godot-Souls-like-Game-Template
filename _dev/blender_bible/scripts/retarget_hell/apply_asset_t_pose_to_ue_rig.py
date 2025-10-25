import bpy
from mathutils import Vector, Euler, Quaternion
import re

__all__ = ["apply_pose_asset"]

def apply_pose_asset(armature_name: str, pose_asset_name: str) -> None:
    def dbg(*a): print("[apply_pose_asset]", *a)

    def find_pose_action(name: str):
        for act in bpy.data.actions:
            if act.name == name and getattr(act, "asset_data", None):
                return act
        return None

    def pick_frame(act, marker_name: str):
        if getattr(act, "pose_markers", None):
            for m in act.pose_markers:
                if m.name.strip().lower() == marker_name.strip().lower():
                    return int(m.frame), f'marker "{m.name}"'
            m = act.pose_markers[0]
            return int(m.frame), f'first marker "{m.name}"'
        return int(act.frame_range[0]), "action start"

    def parse_path(p: str):
        m = re.match(r'pose\.bones\["([^"]+)"\]\.(rotation_quaternion|rotation_euler|location|scale)$', p)
        return (m.group(1), m.group(2)) if m else (None, None)

    def collect_values(act, frame: int):
        data = {}
        for fc in act.fcurves:
            bone, prop = parse_path(fc.data_path)
            if not bone:
                continue
            slot = data.setdefault(bone, {}).setdefault(prop, {})
            slot[fc.array_index] = fc.evaluate(frame)
        return data

    def apply_to_armature(arm, values):
        applied, missing = 0, []
        for name, props in values.items():
            pb = arm.pose.bones.get(name)
            if not pb:
                missing.append(name)
                continue

            # location
            if "location" in props:
                loc = props["location"]
                pb.location = Vector([loc.get(i, 0.0) for i in range(3)])

            # scale
            if "scale" in props:
                scl = props["scale"]
                pb.scale = Vector([scl.get(i, 1.0) for i in range(3)])

            # rotation (prefer quaternion if present)
            if "rotation_quaternion" in props:
                rq = props["rotation_quaternion"]
                quat = Quaternion([rq.get(0, 1.0), rq.get(1, 0.0), rq.get(2, 0.0), rq.get(3, 0.0)])  # (w,x,y,z)
                pb.rotation_mode = 'QUATERNION'
                pb.rotation_quaternion = quat
            elif "rotation_euler" in props:
                reu = props["rotation_euler"]
                eul = Euler([reu.get(i, 0.0) for i in range(3)], 'XYZ')
                pb.rotation_mode = 'XYZ'
                pb.rotation_euler = eul

            applied += 1
        return applied, missing

    # --- main flow ---
    arm = bpy.data.objects.get(armature_name)
    assert arm and arm.type == 'ARMATURE', f'Armature not found: {armature_name}'
    act = find_pose_action(pose_asset_name)
    assert act, f'Pose Asset Action not found: {pose_asset_name}'

    # Pose mode + select all (visibility only)
    if bpy.context.mode != 'OBJECT':
        bpy.ops.object.mode_set(mode='OBJECT', toggle=False)
    bpy.ops.object.select_all(action='DESELECT')
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE', toggle=False)
    bpy.ops.pose.select_all(action='SELECT')

    frame, src = pick_frame(act, pose_asset_name)
    dbg(f'Using frame {frame} from {src}')

    vals = collect_values(act, frame)
    dbg(f'Bones with data: {len(vals)}')

    applied, missing = apply_to_armature(arm, vals)
    dbg(f'Applied to {applied} bones on "{armature_name}".')
    if missing:
        dbg(f'Not found on rig (first few): {missing[:8]}')

    dbg("Done.")
