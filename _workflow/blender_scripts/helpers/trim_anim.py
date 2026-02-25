import bpy, os, sys, importlib # pyright: ignore[reportMissingImports]

# CONFIG trim_specific_anim
ACTION_NAME   = ""         # real name or "". "" means using armature's current action
ARMATURE_NAME = "Armature" # used when ACTION_NAME == ""
CUT_START     = 51         # inclusive
CUT_END       = 0          # inclusive; 0 = use real last frame


# CONFIG  trim_last_frame_for_all_anims_with_prefix
PREFIX = "SWSl O" # trim last frame for all actions starting with this


# os.path.dirname(bpy.data.filepath)
SCRIPTS_DIR = os.path.normpath(r"C:\safe\godot\projects\retroroom\RetroRoom\_dev\blender_scripts")

def _add_path(p):
    if p not in sys.path:
        sys.path.insert(0, p)
_add_path(SCRIPTS_DIR)

import copy_actions_or_change_names

importlib.reload(copy_actions_or_change_names)

def _insert_key_if_missing(fc, frame, value):
    for kp in fc.keyframe_points:
        if abs(kp.co[0] - frame) < 1e-6:
            return False
    kp = fc.keyframe_points.insert(frame=frame, value=value, options={'FAST'})
    kp.handle_left[0] = kp.handle_right[0] = frame
    kp.handle_left[1] = kp.handle_right[1] = value
    return True


def _resolve_action(action_name: str, armature_name: str) -> bpy.types.Action | None:
    if action_name:
        return bpy.data.actions.get(action_name)
    arm = bpy.data.objects.get(armature_name)
    if not arm:
        print(f"[cut] Armature '{armature_name}' not found.")
        return None
    anim = arm.animation_data
    if not (anim and anim.action):
        print(f"[cut] Armature '{armature_name}' has no current action on AnimData.")
        return None
    return anim.action


def _cut_action_keep_range(act: bpy.types.Action, fs: int, fe: int):
    assert fe >= fs, "CUT_END must be >= CUT_START"
    for fc in act.fcurves:
        _insert_key_if_missing(fc, fs, fc.evaluate(fs))
        _insert_key_if_missing(fc, fe, fc.evaluate(fe))
        kps = fc.keyframe_points
        for i in reversed(range(len(kps))):
            f = kps[i].co[0]
            if f < fs or f > fe:
                kps.remove(kps[i])
        fc.update()
    act.use_frame_range = True
    act.frame_start = fs
    act.frame_end = fe


def trim_specific_anim():
    act = _resolve_action(ACTION_NAME, ARMATURE_NAME)
    if not act:
        return

    act_fs = int(act.frame_range[0])
    act_fe = int(act.frame_range[1])

    fs = max(int(CUT_START), act_fs)
    fe_req = int(CUT_END)
    fe = act_fe if fe_req == 0 else min(fe_req, act_fe)

    if fe < fs:
        print(f"[cut] {act.name}: nothing to cut (resolved fe < fs: {fe} < {fs})")
        return

    _cut_action_keep_range(act, fs, fe)
    print(f"[cut] {act.name}: kept [{fs}..{fe}]")


def trim_last_frame_for_all_anims_with_prefix(prefix: str):
    names = copy_actions_or_change_names.get_actions_by_prefix(prefix)  # assumed provided
    if not names:
        print(f"[trim-last] No actions found for prefix '{prefix}'.")
        return

    processed = 0
    skipped = []

    for name in names:
        act = bpy.data.actions.get(name)
        if not act:
            continue

        fs = int(act.frame_range[0])  # original start (inclusive)
        fe = int(act.frame_range[1])  # original end   (inclusive)
        new_end = fe - 1              # drop the last frame

        if new_end < fs:
            skipped.append((name, fs, fe))
            continue

        _cut_action_keep_range(act, fs, new_end)  # assumed provided
        print(f"[trim-last] {name}: [{fs}..{fe}] -> [{fs}..{new_end}]")
        processed += 1

    print(f"[trim-last] Done. Processed {processed} action(s).")
    if skipped:
        for n, s, e in skipped:
            print(f"[trim-last] Skipped '{n}' (range [{s}..{e}] too small to trim)")


if __name__ == "__main__":
    print("")
#    trim_specific_anim()
    trim_last_frame_for_all_anims_with_prefix(PREFIX)
