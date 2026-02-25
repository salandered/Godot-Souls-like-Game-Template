import bpy

# grid spacing
spacing = 3
X_SHIFT = -0
Z_SHIFT = -0

# get selected objects
objs = [o for o in bpy.context.selected_objects if o.type == 'MESH']

# arrange in grid
cols = int(len(objs)**0.5) + 1
for i, obj in enumerate(objs):
    row = i // cols
    col = i % cols
    obj.location.x = col * spacing + X_SHIFT
    obj.location.y = row * spacing
    obj.location.z = Z_SHIFT