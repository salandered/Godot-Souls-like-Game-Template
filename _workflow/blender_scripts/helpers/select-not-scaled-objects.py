
## Select visible objects with unapplied scale

import bpy
from math import isclose

EPS = 1e-4          # tolerance for "applied" scale
ONLY_MESHES = True  # True = check Mesh objects only



def scale_is_applied(obj, eps=EPS):
    sx, sy, sz = obj.scale
    return (
        isclose(sx, 1.0, abs_tol=eps)
        and isclose(sy, 1.0, abs_tol=eps)
        and isclose(sz, 1.0, abs_tol=eps)
    )

def main():
    view_layer = bpy.context.view_layer
    candidates = view_layer.objects

    # filter by visibility and type
    if ONLY_MESHES:
        candidates = [o for o in candidates if o.visible_get() and o.type == 'MESH']
    else:
        candidates = [o for o in candidates if o.visible_get()]

    # deselect all
    bpy.ops.object.select_all(action='DESELECT')

    # find the bad ones
    bad = []
    for o in candidates:
        if not scale_is_applied(o):
            o.select_set(True)
            bad.append(o)

    # set one active
    if bad:
        view_layer.objects.active = bad[0]

    print(f"Found {len(bad)} visible object(s) with unapplied scale.")
    if bad:
        print("Names:", [o.name for o in bad])

if __name__ == "__main__":
    main()
