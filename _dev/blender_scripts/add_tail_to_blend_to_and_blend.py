import bpy

# ---------- CONFIG ----------
SOURCE_ANIMATION_NAME = "L Jog Forward v2 CHANGED LOOP"
TARGET_ANIMATION_NAME = "L RM Idle To Sprint BLENDED"
CUTOFF_FRAME = 20 # non including 
# we want to cut after 19, but need Root data from 20
# ---------- CONFIG ----------
SOURCE_FRAME = 1.0
TARGET_FRAME = 20.0
# ----------------------------

# blend
TARGET_FRAME = 20
TAIL_FRAMES = 10

def get_actions_or_fail(source_name, target_name):
    actions = bpy.data.actions
    source_action = actions.get(source_name)
    if source_action is None:
        raise Exception("not good, there is no action by name")
    target_action = actions.get(target_name)
    if target_action is None:
        raise Exception("not good, there is no action by name")
    return source_action, target_action

def delete_frames_after(target_action):
    deleted = 0
    unique_frames = set()
    for fcurve in target_action.fcurves:
        kps = fcurve.keyframe_points
        for i in range(len(kps) - 1, -1, -1):
            frame = kps[i].co.x
            if frame > CUTOFF_FRAME:
                unique_frames.add(int(round(frame)))
                kps.remove(kps[i])
                deleted += 1
        fcurve.update()
    print(f"deleted {deleted} keyframes after frame {int(CUTOFF_FRAME)} (affected frames: {len(unique_frames)})")

def copy_frame(target_action, source_action, without_root: bool = True):
    added = 0
    overridden = 0
    skipped_root = 0
  
    def is_root_channel(fcurve):
        if fcurve.group and fcurve.group.name == "Root":
            return True
        dp = fcurve.data_path
        return dp.startswith('pose.bones["Root"') or dp.startswith("pose.bones['Root'")

    target_lookup = {(f.data_path, f.array_index): f for f in target_action.fcurves}

    for source_fcurve in source_action.fcurves:
        if without_root and is_root_channel(source_fcurve):
            skipped_root += 1
            continue

        value = source_fcurve.evaluate(SOURCE_FRAME)
        key = (source_fcurve.data_path, source_fcurve.array_index)
        target_fcurve = target_lookup.get(key)
        if target_fcurve is None:
            group = source_fcurve.group.name if source_fcurve.group else None
            target_fcurve = target_action.fcurves.new(
                source_fcurve.data_path,
                index=source_fcurve.array_index,
                action_group=group
            )
            target_lookup[key] = target_fcurve

        had_key_at_target = any(abs(k.co.x - TARGET_FRAME) < 1e-6 for k in target_fcurve.keyframe_points)
        inserted = target_fcurve.keyframe_points.insert(TARGET_FRAME, value, options={'FAST'})
        if source_fcurve.keyframe_points:
            inserted.interpolation = source_fcurve.keyframe_points[0].interpolation
        target_fcurve.update()

        if had_key_at_target:
            overridden += 1
        added += 1

    if overridden:
        print(f"warning: overriding {overridden} existing non-root keys at frame {int(TARGET_FRAME)}")
    if without_root and skipped_root:
        print(f"skipped root channels: {skipped_root}")
    print(f"copied frame {int(SOURCE_FRAME)} -> {int(TARGET_FRAME)} across {added} fcurves")

def _insert_or_set(fc: bpy.types.FCurve, frame: int, value: float) -> None:
    # overwrite if a key at 'frame' exists; else insert
    for kp in fc.keyframe_points:
        if abs(kp.co[0] - frame) < 1e-6:
            kp.co[1] = value
            kp.handle_left[1]  = value
            kp.handle_right[1] = value
            return
    kp = fc.keyframe_points.insert(frame=frame, value=value, options={'FAST'})
    kp.handle_left[1]  = value
    kp.handle_right[1] = value


def add_one_frame_copy_first_to_new_last(action_name: str) -> None:
    """
    1) Add +1 frame to the action, copying the FIRST frame's values to the NEW LAST frame.
    """
    act = bpy.data.actions[action_name]
    fs, fe = int(act.frame_range[0]), int(act.frame_range[1])
    if fe < fs:
        print(f"[step1] '{act.name}' empty range.")
        return

    new_last = fe + 1
    for fc in act.fcurves:
        v0 = fc.evaluate(fs)
        _insert_or_set(fc, new_last, v0)
        fc.update()

    # extend manual range to include the new last frame
    act.use_frame_range = True
    act.frame_start = fs
    act.frame_end = new_last
    print(f"[step1] '{act.name}': copied frame {fs} → new last {new_last}. Range [{fs}..{new_last}].")


def blend_tail_to_frame(action_name: str, tail_frames: int) -> None:
    """
    2) Blend the last N frames TOWARD the CURRENT last frame's values.
       (Assumes last frame already has the target pose.)
    """
    act = bpy.data.actions[action_name]
    fs, fe = int(act.frame_range[0]), int(act.frame_range[1])
    if fe <= fs or tail_frames <= 0:
        print(f"[step2] '{act.name}': nothing to do (range [{fs}..{fe}], tail={tail_frames}).")
        return

    start = max(fs + 1, fe - tail_frames)  # blend over [start .. fe-1]; keep 'fe' as the target
    if start >= fe:
        print(f"[step2] '{act.name}': tail start >= end; nothing to do.")
        return

    for fc in act.fcurves:
        v_end = fc.evaluate(fe)
        for f in range(start, fe):
            # alpha: 0 at 'start', 1 at 'fe'
            alpha = (f - start) / (fe - start)
            v_orig = fc.evaluate(f)
            v_blend = (1.0 - alpha) * v_orig + alpha * v_end
            _insert_or_set(fc, f, v_blend)
        fc.update()

    print(f"[step2] '{act.name}': blended {start}..{fe-1} → frame {fe}.")

def main():
    source_action, target_action = get_actions_or_fail(SOURCE_ANIMATION_NAME, TARGET_ANIMATION_NAME)
#    print(f"source '{source_action.name}' -> target '{target_action.name}'")
#    delete_frames_after(target_action)
#    copy_frame(target_action, source_action)
    blend_tail_to_frame(action_name=TARGET_ANIMATION_NAME, tail_frames= TAIL_FRAMES)

if __name__ == "__main__":
    main()
