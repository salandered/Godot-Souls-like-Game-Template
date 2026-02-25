import bpy

# --- config ---
ARMATURE_NAME = "Armature"          # your rig object
ACTION_NAME   = "OS block right"      # the action to fix
ROOT_BONE     = "Root"
HIPS_BONE     = "Hips"
AXES          = ("X", "Z")          # which components to transfer

_AXIS = {"X": 0, "Y": 1, "Z": 2}

def _fcurve_get(act, bone, prop, idx):
    data_path = f'pose.bones["{bone}"].{prop}'
    return next((f for f in act.fcurves if f.data_path == data_path and f.array_index == idx), None)

def _fcurve_get_or_new(act, bone, prop, idx):
    fc = _fcurve_get(act, bone, prop, idx)
    if fc: return fc
    return act.fcurves.new(data_path=f'pose.bones["{bone}"].{prop}', index=idx)

def _eval_or_zero(fc, frame):
    return fc.evaluate(frame) if fc else 0.0

def _set_key(fc, frame, value):
    # if a key at 'frame' exists, overwrite it; else insert
    for kp in fc.keyframe_points:
        if abs(kp.co[0] - frame) < 1e-6:
            kp.co[1] = value
            # keep handle Y consistent
            kp.handle_left[1]  = value
            kp.handle_right[1] = value
            return
    kp = fc.keyframe_points.insert(frame=frame, value=value, options={'FAST'})
    # keep tangents level (helps prevent tiny overshoot)
    kp.handle_left[1]  = value
    kp.handle_right[1] = value

def transfer_root_to_hips(arm_name, action_name, root_bone, hips_bone, axes=("X","Z")):
    arm = bpy.data.objects[arm_name]
    act = bpy.data.actions[action_name]

    # make sure this action is the one being evaluated for this object
    anim = arm.animation_data_create()
    anim.action = act

    fs, fe = int(act.frame_range[0]), int(act.frame_range[1])

    # prepare fcurves
    root_fcs = {ax: _fcurve_get(act, root_bone, "location", _AXIS[ax]) for ax in axes}
    hips_fcs = {ax: _fcurve_get(act, hips_bone, "location", _AXIS[ax]) for ax in axes}
    # ensure targets exist for writing
    hips_dst = {ax: _fcurve_get_or_new(act, hips_bone, "location", _AXIS[ax]) for ax in axes}
    root_dst = {ax: _fcurve_get_or_new(act, root_bone, "location", _AXIS[ax]) for ax in axes}

    print(f"[transfer] Action='{action_name}' frames [{fs}..{fe}] | move {axes} from {root_bone} → {hips_bone}")

    changed = False
    for f in range(fs, fe + 1):
        # read current values (0 if channel missing)
        root_vals = {ax: _eval_or_zero(root_fcs[ax], f) for ax in axes}
        hips_vals = {ax: _eval_or_zero(hips_fcs[ax], f) for ax in axes}

        # compute new values
        new_hips = {ax: hips_vals[ax] + root_vals[ax] for ax in axes}
        new_root = {ax: 0.0 for ax in axes}

        # write keys
        for ax in axes:
            _set_key(hips_dst[ax], f, new_hips[ax])
            _set_key(root_dst[ax], f, new_root[ax])

        changed = True

    # update curves
    for ax in axes:
        hips_dst[ax].update()
        root_dst[ax].update()

    if changed:
        print(f"[transfer] Done. {root_bone}.{axes} → {hips_bone}.{axes}. Root {axes} set to 0 over full range.")
    else:
        print("[transfer] Nothing changed (no frames or channels).")

if __name__ == "__main__":
    transfer_root_to_hips(ARMATURE_NAME, ACTION_NAME, ROOT_BONE, HIPS_BONE, AXES)
