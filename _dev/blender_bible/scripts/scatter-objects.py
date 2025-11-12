import bpy

# grid spacing
spacing = 8
X_SHIFT = -180

# get selected objects
objs = [o for o in bpy.context.selected_objects if o.type == 'MESH']

# arrange in grid
cols = int(len(objs)**0.5) + 1
for i, obj in enumerate(objs):
    row = i // cols
    col = i % cols
    obj.location.x = col * spacing + X_SHIFT
    obj.location.y = row * spacing
    obj.location.z = 12