import bpy

REF_NAME = "|col ref to share mods|"
COLL_NAME = "--collisions-exit2--"

def ensure_collection(name: str):
    coll = bpy.data.collections.get(name)
    if not coll:
        coll = bpy.data.collections.new(name)
        if bpy.context.scene:
            bpy.context.scene.collection.children.link(coll)
    return coll

def parent_keep_transform(child, parent):
    mw = child.matrix_world.copy()
    child.parent = parent
    child.matrix_parent_inverse = parent.matrix_world.inverted() @ mw
    child.matrix_world = mw


def copy_modifiers_from_to(src: bpy.types.Object, dst: bpy.types.Object):
    prev_active = bpy.context.view_layer.objects.active
    prev_sel = list(bpy.context.selected_objects)

    bpy.ops.object.select_all(action='DESELECT')
    dst.select_set(True)
    src.select_set(True)
    bpy.context.view_layer.objects.active = src
    try:
        bpy.ops.object.make_links_data(type='MODIFIERS')
    finally:
        bpy.ops.object.select_all(action='DESELECT')
        for o in prev_sel:
            o.select_set(True)
        bpy.context.view_layer.objects.active = prev_active

def copy_materials_from_ref(ref: bpy.types.Object, obj: bpy.types.Object):
    ref_mats = [ms.material for ms in ref.material_slots if ms.material]
    if not ref_mats:
        return
    if not obj.material_slots:
        return
    for i, slot in enumerate(obj.material_slots):
        if hasattr(slot, "link"):
            slot.link = 'OBJECT'
        slot.material = ref_mats[min(i, len(ref_mats) - 1)]

def make_colonly_for(target: bpy.types.Object, ref: bpy.types.Object, coll: bpy.types.Collection):
    B = target.copy()
    
    # --- THIS IS THE CHANGE ---
    # Make a full copy (unlinked mesh) instead of sharing data
    B.data = target.data.copy()
    # --- END OF CHANGE ---
    
    B.name = f"{target.name}-colonly"
    B.matrix_world = target.matrix_world.copy()

    if coll not in B.users_collection:
        coll.objects.link(B)

    parent_keep_transform(B, target)

    B.color = ref.color
    B.show_wire = True

    copy_materials_from_ref(ref, B)
    copy_modifiers_from_to(ref, B)

    return B

def main():
    ref = bpy.data.objects.get(REF_NAME)
    if not ref or ref.type != 'MESH':
        raise RuntimeError(f'Reference "{REF_NAME}" not found or not a Mesh.')

    targets = [o for o in bpy.context.selected_objects if o.type == 'MESH' and o != ref]
    if not targets:
        act = bpy.context.view_layer.objects.active
        if act and act.type == 'MESH' and act != ref:
            targets = [act]
    if not targets:
        raise RuntimeError("Select at least one target Mesh object (A).")

    coll = ensure_collection(COLL_NAME)

    created = []
    for t in targets:
        created.append(make_colonly_for(t, ref, coll))

    print(f"Created {len(created)} objects:", [o.name for o in created])

if __name__ == "__main__":
    main()