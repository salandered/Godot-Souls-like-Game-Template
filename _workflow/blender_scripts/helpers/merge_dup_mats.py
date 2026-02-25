import bpy
import re

def merge_duplicate_materials():
    # Regex to find names ending in .001, .002, .070 etc.
    # It looks for a "dot" followed by digits at the end of the string.
    pattern = re.compile(r"^(.+)(\.\d+)$")
    
    # We loop over a copy of the materials list because we might delete some
    mats = bpy.data.materials
    
    count = 0
    
    for mat in list(mats):
        match = pattern.match(mat.name)
        
        if match:
            # "base_name" is the name without the numbers (e.g. "Sandstone_6")
            base_name = match.group(1)
            
            # Check if the original base material actually exists
            if base_name in mats:
                original_mat = mats[base_name]
                
                # Skip if we are somehow trying to replace a material with itself
                if original_mat == mat:
                    continue
                
                print(f"Merging {mat.name} -> {original_mat.name}")
                
                # moves ALL objects using 'mat' to use 'original_mat' instead
                mat.user_remap(original_mat)
                
                # Now that 'mat' has 0 users, we can delete it
                bpy.data.materials.remove(mat)
                count += 1
    
    print(f"--------------------------------------------------")
    print(f"Cleanup Complete. Merged {count} duplicate materials.")
    
    # Optional: Force update the UI to show changes immediately
    for window in bpy.context.window_manager.windows:
        for area in window.screen.areas:
            area.tag_redraw()

# Run the function
merge_duplicate_materials()