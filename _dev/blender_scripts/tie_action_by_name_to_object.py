import bpy

__all__ = ["tie_action_to_object"]

def tie_action_to_object(object_name: str, action_name: str) -> None:
    def dbg(*args):
        print("[tie_action_to_object]", *args)

    # 1) Resolve objects
    obj = bpy.data.objects[object_name]
    act = bpy.data.actions[action_name]
    anim = obj.animation_data_create()

    dbg(f"Object : {obj.name}")
    dbg(f"Action  : {act.name}")
    dbg("---- Action slots on this Action ----")
    for s in act.slots:
        dbg(f"  - name_display='{s.name_display}', identifier='{s.identifier}', handle={s.handle}, target_id_type={s.target_id_type}")

    # 2) Pick slot
    if len(act.slots) == 0:
        # by design: fail fast if the action has no slots
        raise RuntimeError("This Action has no slots; nothing to assign.")
    slot = act.slots[0]
    dbg(f"Picked first slot: '{slot.name_display}' (handle={slot.handle})")

    # 3) Assign
    anim.last_slot_identifier = slot.identifier
    anim.action = act
    anim.action_slot = slot
    anim.action_slot_handle = slot.handle

    dbg("---- Result on AnimData ----")
    dbg(f"anim.action               = {anim.action.name if anim.action else None}")
    dbg(f"anim.action_slot.name_disp= {anim.action_slot.name_display if anim.action_slot else None}")
    dbg(f"anim.action_slot_handle   = {anim.action_slot_handle}")
    dbg(f"anim.last_slot_identifier = {anim.last_slot_identifier}")

if __name__ == "__main__":
    # quick local test: change these to your actual names
    OBJECT_NAME = "Empty"
    ACTION_NAME = "block right"
    tie_action_to_object(OBJECT_NAME, ACTION_NAME)
