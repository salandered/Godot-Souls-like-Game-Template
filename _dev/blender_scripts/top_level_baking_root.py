# Top-level: link base actions to Empty, link "<name> retarget" to Armature,
# copy root location from Empty, then bake. Skips actions containing "retarget"/"t pose".
# Continues if the retarget version is missing.

import bpy, os, sys, importlib

# --- config ---
ARMATURE_NAME = "Armature"
EMPTY_NAME    = "Empty"
ROOT_BONE     = "Root"

_scripts_dir = os.path.normpath(r"C:\safe\godot\projects\retroroom\RetroRoom\_dev\blender_scripts")
#os.path.dirname(bpy.path.abspath(bpy.data.filepath))
if _scripts_dir and _scripts_dir not in sys.path:
    sys.path.insert(0, _scripts_dir)

# helpers (filenames must match)
import copy_actions_or_change_names
import clear_loc_rot
import tie_action_by_name_to_object
import rig_bone_copies_empty_location
import bake_root_constraint

def dbg(*args):
    print("[top_retarget_to_empty_then_bake]", *args)

def reload_helpers():
    importlib.reload(copy_actions_or_change_names)
    importlib.reload(clear_loc_rot)
    importlib.reload(tie_action_by_name_to_object)
    importlib.reload(rig_bone_copies_empty_location)
    importlib.reload(bake_root_constraint)


def find_retarget_name(base_name: str, prefix_to_remove: str):
    cleaned_base_name = base_name
    
    # Step 1: Remove the specified prefix from the base_name if it exists.
    if prefix_to_remove and base_name.startswith(prefix_to_remove):
        cleaned_base_name = base_name.removeprefix(prefix_to_remove).strip()
        
    # Step 2: Construct the single, case-sensitive candidate name.
    # The postfix must be exactly "Retarget".
    candidate_name = f"{cleaned_base_name} Retarget"
    
    # Step 3: Check if an action with this exact name exists and return it.
    if candidate_name in bpy.data.actions:
        return candidate_name
        
    return None

def process_action(action_name: str, retarget_name: str):
    dbg(f"--- {action_name} ---")
    
    
    clear_loc_rot.clear_object_loc_rot(ARMATURE_NAME)

    # 1) link base action to the Empty
    tie_action_by_name_to_object.tie_action_to_object(EMPTY_NAME, action_name)
    dbg(f"  linked '{action_name}' -> Empty '{EMPTY_NAME}'")

    # 2) link retarget action to the Armature
    tie_action_by_name_to_object.tie_action_to_object(ARMATURE_NAME, retarget_name)
    dbg(f"  linked '{retarget_name}' -> Armature '{ARMATURE_NAME}'")

    # 3) copy root bone location from Empty
    rig_bone_copies_empty_location.copy_root_location_from_empty(ARMATURE_NAME, ROOT_BONE, EMPTY_NAME)
    dbg("  applied Copy Location to root")

    # 4) bake root bone over scene range (visual, clears constraint)
    ret_act = bpy.data.actions[retarget_name]
    fs = int(ret_act.frame_range[0])
    fe = int(ret_act.frame_range[1])
    bake_root_constraint.bake_root_bone(ARMATURE_NAME, ROOT_BONE, frame_start=fs, frame_end=fe)
    dbg(f"  baked root bone [{fs}..{fe}]")
    

    arm = bpy.data.objects["Armature"]
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='OBJECT')


def main():
    dbg("\n\n")
    reload_helpers()

    base_names = copy_actions_or_change_names.get_actions_by_prefix(prefix="RM O")
    if not base_names:
        dbg("No candidate actions found.")
        return
    dbg(f"Found {len(base_names)} base actions to process.")

    for base_name in base_names[:1]:
        dbg(f" Fake run for '{base_name}'.")
        retarget_name = find_retarget_name(base_name, prefix_to_remove="RM ")
        if not retarget_name:
            dbg("  retarget action not found; skipping to next.")
            continue
        else:
            dbg(f"  retarget action found '{retarget_name}'")
#        process_action(base_name, retarget_name)

    dbg("Done.")

if __name__ == "__main__":
    main()
