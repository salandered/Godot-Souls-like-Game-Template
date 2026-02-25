import bpy

# The frame u want to become the new start of the animation.
NEW_START_FRAME = 12

# The current start and end frames of the animation's content.
# For 26 frames where 26=1, the content is from 1 to 25.
ANIMATION_START_FRAME = 1
ANIMATION_END_FRAME = 25


def offset_animation_loop(armature_obj, new_start, current_start, current_end):
    """
    Offsets all keyframes of the active action on an armature.
    Keyframes are "rolled" so that a new start frame is established,
    wrapping previous keyframes to the end of the loop.
    """
    if not armature_obj or armature_obj.type != 'ARMATURE':
        raise Exception("A valid Armature object was not provided.")

    action = armature_obj.animation_data.action
    if not action:
        raise Exception(f"Armature '{armature_obj.name}' has no active Action.")

    # Calculate loop duration and the amount to shift keyframes
    loop_duration = (current_end - current_start) + 1
    offset = new_start - current_start

    print(f"Offsetting '{action.name}' by {-offset} frames...")

    # Process every f-curve (every animated property)
    for fcurve in action.fcurves:
        new_points = []
        for keyframe in fcurve.keyframe_points:
            old_frame = keyframe.co.x
            
            # Calculate the new frame number
            new_frame = old_frame - offset
            
            # Wrap the keyframe around if it's now before the start
            if new_frame < current_start:
                new_frame += loop_duration
                
            new_points.append((new_frame, keyframe.co.y))

        # Clear the old keyframes and add the new ones
        fcurve.keyframe_points.clear()
        for frame, value in new_points:
            fcurve.keyframe_points.insert(frame, value)
            
        fcurve.update()

    print("Animation offset complete.")


# Get the currently selected object in the 3D Viewport
selected_object = bpy.context.active_object

# Call the function with the selected object and the config
try:
    offset_animation_loop(
        selected_object,
        NEW_START_FRAME,
        ANIMATION_START_FRAME,
        ANIMATION_END_FRAME
    )
except Exception as e:
    print(f"ERROR: {e}")