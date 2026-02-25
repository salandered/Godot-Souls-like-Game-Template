import bpy


ACTION_NAME = "SWSl O run L test"
TAIL_FRAMES = 6

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


def blend_tail_toward_last(action_name: str, tail_frames: int = 6) -> None:
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


def delete_last_frame(action_name: str) -> None:
    """
    3) Delete the LAST frame from the action (remove keys at last frame and
       set the manual range to end one frame earlier).
    """
    act = bpy.data.actions[action_name]
    fs, fe = int(act.frame_range[0]), int(act.frame_range[1])
    if fe <= fs:
        print(f"[step3] '{act.name}': nothing to delete (range [{fs}..{fe}]).")
        return

    new_end = fe - 1
    for fc in act.fcurves:
        kps = fc.keyframe_points
        for i in reversed(range(len(kps))):
            if kps[i].co[0] >= fe - 1e-6:  # remove keys at the last frame
                kps.remove(kps[i])
        fc.update()

    act.use_frame_range = True
    act.frame_start = fs
    act.frame_end = new_end
    print(f"[step3] '{act.name}': deleted last frame {fe} → new range [{fs}..{new_end}].")



if __name__ == "__main__":
    print("")
    add_one_frame_copy_first_to_new_last(action_name=ACTION_NAME)
#    blend_tail_toward_last(action_name =ACTION_NAME, tail_frames= TAIL_FRAMES)
#    delete_last_frame(action_name=ACTION_NAME)

