# Blender 4.x — Create "-colonly" child copies for selected objects (A),
# using a NAMED reference object (F) to copy materials/modifiers/viewport color.

import bpy

REF_NAME = "__col_reference"        # <<< set this to your reference object's name
COLL_NAME = "-- collisions tower--"  # target collection name

def ensure_collection(name: str):
    coll = bpy.data.collections.get(name)
    if not coll:
        coll = bpy.data.collections.new(name)
        # link to scene root so it's visible/usable
        if bpy.context.scene:
            bpy.context.scene.collection.children.link(coll)
    return coll

def parent_keep_transform(child, parent):
    # store world before parenting
    mw = child.matrix_world.copy()
    child.parent = parent
    # keep the same world transform
    child.matrix_parent_inverse = parent.matrix_world.inverted() @ mw
    child.matrix_world = mw


def copy_modifiers_from_to(src: bpy.types.Object, dst: bpy.types.Object):
    # Replicates Ctrl+L → Modifiers (copies, not links)
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
    # Per-object material override using OBJECT link (keeps shared mesh intact)
    ref_mats = [ms.material for ms in ref.material_slots if ms.material]
    if not ref_mats:
        return
    if not obj.material_slots:
        # don't add slots (would touch shared mesh); just skip
        return
    for i, slot in enumerate(obj.material_slots):
        if hasattr(slot, "link"):
            slot.link = 'OBJECT'
        slot.material = ref_mats[min(i, len(ref_mats) - 1)]

def make_colonly_for(target: bpy.types.Object, ref: bpy.types.Object, coll: bpy.types.Collection):
    # duplicate object (shares mesh datablock), parent to A, set name, link to collection
    B = target.copy()
    B.data = target.data  # be explicit about sharing mesh
    B.name = f"{target.name}-colonly"
    B.matrix_world = target.matrix_world.copy()

    # link to collisions collection
    if coll not in B.users_collection:
        coll.objects.link(B)

    # parent under A (keep transforms)
    parent_keep_transform(B, target)

    # viewport display tweaks
    B.color = ref.color
    B.show_wire = True
    # hard wireframe draw mode instead
    # B.display_type = 'WIRE'

    # copy mats & modifiers from reference F
    copy_materials_from_ref(ref, B)
    copy_modifiers_from_to(ref, B)

    return B

def main():
    ref = bpy.data.objects.get(REF_NAME)
    if not ref or ref.type != 'MESH':
        raise RuntimeError(f'Reference "{REF_NAME}" not found or not a Mesh.')

    # Targets = all selected mesh objects except the reference (u only need to select A)
    targets = [o for o in bpy.context.selected_objects if o.type == 'MESH' and o != ref]
    if not targets:
        # fallback: use active if it’s a mesh and not the ref
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
