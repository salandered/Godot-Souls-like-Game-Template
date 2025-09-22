import bpy # pyright: ignore[reportMissingImports]

# --- config ---
ACTION_NAME   = ""              # "" => use armature's current AnimData action
ARMATURE_NAME = "Armature"      # used when ACTION_NAME == ""
CUT_START     = 51             # inclusive
CUT_END       = 0               # inclusive; 0 = use real last frame

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

def cut_action_keep_range(act: bpy.types.Action, fs: int, fe: int):
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

def main():
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

    cut_action_keep_range(act, fs, fe)
    print(f"[cut] {act.name}: kept [{fs}..{fe}]")

if __name__ == "__main__":
    main()
