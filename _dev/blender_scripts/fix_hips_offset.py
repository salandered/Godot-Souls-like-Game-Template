import bpy

# --- config ---
PREFIX         = "OS"          # actions starting with this
HIP_BONE_NAME  = "Hips"        # pelvis/hips bone
TARGETS        = {"X": 0.0, "Z": -0.02835}  # per-axis first-frame targets
THRESHOLD      = 0.5          # fix only if |value - target| > THRESHOLD
AXES           = ("X", "Z")    # axes to check/fix

SPECIFIC_ACTION = "OS block right" # Str or null

_AXIS_TO_INDEX = {"X": 0, "Y": 1, "Z": 2}

def _probe_fcurve_value(act: bpy.types.Action, bone: str, axis: str):
    array_index = _AXIS_TO_INDEX[axis]
    data_path = f'pose.bones["{bone}"].location'
    fc = next((f for f in act.fcurves if f.data_path == data_path and f.array_index == array_index), None)
    if fc is None:
        return None, None, None  # no channel
    first_frame = int(act.frame_range[0])
    cur = fc.evaluate(first_frame)
    return fc, first_frame, cur

def _shift_curve_to_target(act: bpy.types.Action, bone: str, axis: str, target_first: float, threshold: float):
    """
    Shift the bone's location fcurve on 'axis' so first frame hits target.
    Returns dict with details:
      {"status": "fixed"/"within_threshold"/"missing",
       "axis": axis, "frame": fs, "current": cur, "target": target, "delta": delta, "applied": applied}
    """
    fc, fs, cur = _probe_fcurve_value(act, bone, axis)
    if fc is None:
        return {"status": "missing", "axis": axis, "frame": None, "current": None, "target": target_first, "delta": None, "applied": 0.0}

    delta = cur - target_first
    if abs(delta) <= threshold:
        return {"status": "within_threshold", "axis": axis, "frame": fs, "current": cur, "target": target_first, "delta": delta, "applied": 0.0}

    # apply shift -delta to all keys (and handles)
    for kp in fc.keyframe_points:
        kp.co[1]         -= delta
        kp.handle_left[1]  -= delta
        kp.handle_right[1] -= delta
    fc.update()

    return {"status": "fixed", "axis": axis, "frame": fs, "current": cur, "target": target_first, "delta": delta, "applied": -delta}

def main():
    fixed_actions = []
    untouched_actions = []
    missing_any_channel = []

    print(f"[normalize] Scanning actions with prefix '{PREFIX}' | bone='{HIP_BONE_NAME}', targets={TARGETS}, threshold={THRESHOLD}")

    for act in list(bpy.data.actions):
        if not act.name.startswith(PREFIX):
            continue

        print(f"\n[normalize] === {act.name} ===")
        per_axis_results = []
        for axis in AXES:
            target = TARGETS[axis]
            res = _shift_curve_to_target(act, HIP_BONE_NAME, axis, target, THRESHOLD)
            per_axis_results.append(res)

            if res["status"] == "missing":
                print(f"  - {axis}: MISSING channel -> no changes (target {target:+.6f})")
            elif res["status"] == "within_threshold":
                print(f"  - {axis}: OK (frame {res['frame']}) current {res['current']:+.6f} within ±{THRESHOLD} of target {res['target']:+.6f}")
            elif res["status"] == "fixed":
                print(f"  - {axis}: FIXED (frame {res['frame']}) current {res['current']:+.6f} -> target {res['target']:+.6f} (applied {res['applied']:+.6f})")

        any_fixed = any(r["status"] == "fixed" for r in per_axis_results)
        any_missing = any(r["status"] == "missing" for r in per_axis_results)

        if any_fixed:
            fixed_actions.append(act.name)
        else:
            untouched_actions.append(act.name)

        if any_missing:
            missing_any_channel.append(act.name)

    # --- summary ---
    print("\n[normalize] ===== SUMMARY =====")
    print(f"Fixed actions ({len(fixed_actions)}): {', '.join(fixed_actions) if fixed_actions else '—'}")
    print(f"Untouched actions ({len(untouched_actions)}): {', '.join(untouched_actions) if untouched_actions else '—'}")
    if missing_any_channel:
        print(f"Actions missing at least one X/Z channel ({len(missing_any_channel)}): {', '.join(missing_any_channel)}")
    print("[normalize] Done.")

if __name__ == "__main__":
    main()
