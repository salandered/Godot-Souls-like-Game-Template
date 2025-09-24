import bpy, os, sys, importlib



# CHECKLIST
# Config vars assigned
# Pose Library addon turned on!
# Rokoko addon turned on!
# Rokoko settings set in UI
#       - armatures selected
#       - bone map is ok
#       - autoscale ON (might try wo it)
#       - Current pose is ON
# Both armatures VISIBLE
# [Optionally] Source armature RM copied and deleted
# Pose asset clicked/reloaded. Some glitch with a new project

# CONFIG
ARM_SOURCE         = "UE4 Armature"   # source armature
ARM_TARGET     = "Armature"       # retarget-to armature
POSE_ASSET     = "UE4 T Pose 4"     # pose asset to apply to source rig

# All .py modules live next to the .blend (adjust if you move them)
# os.path.dirname(bpy.data.filepath)
SCRIPTS_DIR = os.path.normpath(r"C:\safe\godot\projects\retroroom\RetroRoom\_dev\blender_scripts")

def _add_path(p):
    if p not in sys.path:
        sys.path.insert(0, p)
_add_path(SCRIPTS_DIR)

# =========================
# MODULES (underscore names)
# =========================
import copy_actions_or_change_names
import clear_loc_rot
import apply_asset_t_pose_to_ue_rig
import tie_action_by_name_to_object
import run_rokoko_retarget

# hot-reload while iterating
importlib.reload(copy_actions_or_change_names)
importlib.reload(clear_loc_rot)
importlib.reload(apply_asset_t_pose_to_ue_rig)
importlib.reload(tie_action_by_name_to_object)
importlib.reload(run_rokoko_retarget)

def dbg(*a):
    print("[driver]", *a)


def process_action(action_name: str):
    dbg(f"--- {action_name} ---")
    
    clear_loc_rot.clear_object_loc_rot(ARM_SOURCE)
    clear_loc_rot.clear_object_loc_rot(ARM_TARGET)

    # Link this action to the Source rig + set subset
    dbg(f"tie action '{action_name}' to '{ARM_SOURCE}'")
    tie_action_by_name_to_object.tie_action_to_object(ARM_SOURCE, action_name)
    
    # Alt+G / Alt+R for BOTH armatures
    dbg("clear pose on Source + Target (Alt+G, Alt+R)")
    clear_loc_rot.clear_pose_loc_rot(ARM_SOURCE)
    clear_loc_rot.clear_pose_loc_rot(ARM_TARGET)
    
    # Apply pose asset to the Source rig
    dbg(f"apply pose asset '{POSE_ASSET}' to '{ARM_SOURCE}'")
    apply_asset_t_pose_to_ue_rig.apply_pose_asset(ARM_SOURCE, POSE_ASSET)

    # Run Rokoko retarget (Source -> target)
    dbg(f"rokoko retarget: source='{ARM_SOURCE}', target='{ARM_TARGET}'")
    run_rokoko_retarget.run_retarget(ARM_SOURCE, ARM_TARGET)

    dbg(f"--- done: {action_name} ---\n")

def main():
    dbg(f"\n")
    names = copy_actions_or_change_names.get_filtered_action_names(
        block_words = ["T pose", "T-pose", "Retarget"], block_prefixes = ["RM O"], prefix = "O"
    )
    dbg(f"{len(names)} action(s) gathered") # : {names}")
    failures = []
    for name in names:
        try:
            dbg(f"Fake run for '{name}'")
            process_action(name)
        except Exception as e:
            failures.append((name, repr(e)))
            dbg(f"ERROR on '{name}': {e!r}")
    if failures:
        dbg("Failures:")
        for n, err in failures:
            dbg(f"  {n} -> {err}")
    else:
        dbg("All actions processed.")

if __name__ == "__main__":
    main()
