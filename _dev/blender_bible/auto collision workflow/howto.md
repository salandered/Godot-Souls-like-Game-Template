
Create special "collision-only" child objects for every object you have selected.

These new "colonly" objects share the same mesh data as the orig, but get their materials, modifiers, and viewport color copied from a separate, single reference object.

NOTE: sharing same mesh didnt really work, dont do it. i forgot why

### MAIN

- Create a Reference Object (e.g., a simple cube). Mods:
    - subdivision
    - shrinkwarp
    - decimate collapse
    - decimate planar
    - solidify

     Also: material with light blue and Viewport Display > Color to blue
- Name the Reference: `__col_reference`
-  select all the main objects that you want to create collision copies for
-  run the script


### What the Script Does

It first looks for the object named `__col_reference`. 
Finds/Creates a Collection: It looks for a collection named `-- collisions tower--`
Gets the list of all mesh objects you currently have selected (ignoring the reference object itself).
For each target object u selected:
     It creates a new object (`B = target.copy()`) but makes sure it shares the same mesh data as the original (`B.data = target.data`).
     renames the new object to `[OriginalName]-colonly`.
     parents the new `-colonly` object to its original object, making sure it stays in the same world position (`parent_keep_transform`).
     Moves It: It links the new object into the `-- collisions tower--` collection.
     Copies Properties from Ref:
         copies the viewport color from your `__col_reference` object.
         turns on `show_wire` so the new object displays as a wireframe in the viewport.
         copies all mats from `__col_reference`
         copies all modifiers from `__col_reference`

### Functions Explained

 `make_colonly_for(target, ref, coll)`:core "factory" function that builds the new `-colonly` object. duplicating, parenting, renaming, and calls the helper functions to copy properties.
 `copy_materials_from_ref(ref, obj)`: copies the materials from the `ref` object to the new `obj`. sets the material `link` to `OBJECT`. This allows the new object to have diff mats than the original, even though they share the same mesh data.
 `copy_modifiers_from_to(src, dst)`: mimics the `Ctrl+L` -> "Copy Modifiers" command in Blender. temporarily changes the selection to run the `bpy.ops` command and then restores your original selection.
 `parent_keep_transform(child, parent)`: parents one object to another while calculating the inverse matrix (`matrix_parent_inverse`) needed to keep the child in the same spot.
 `ensure_collection(name)`: helper that checks if a collection exists and creates it if it doesn't.