import bpy
import re
from typing import List


# Just a lot of utils for actions
# getters, renamers, copiers

def add_prefix_to_all_actions(add_prefix: str, filter_prefix: str = "") -> None:
    """
    Adds a add_prefix to the name of every Action in the Blender file.
    Skips any action that already starts with the given prefix.
    """
    # Use get_filtered_action_names with T-pose exclusion
    action_names = get_filtered_action_names(block_words=["t pose", "t-pose"], block_prefixes=[], prefix = filter_prefix)
    actions_to_prefix = [bpy.data.actions[name] for name in action_names]
    
    if not actions_to_prefix:
        print("No Actions found in the file.")
        return
        
    renamed_count = 0
    print(f"--- Adding prefix '{add_prefix}' to all Actions ---")
    
    for action in actions_to_prefix:
        old_name = action.name
        
        # Check if the action already starts with the prefix to avoid duplicates
        # Case-sensitive check for prefix matching
        if old_name.startswith(f"{add_prefix} "):
            print(f"	Skipping '{old_name}', already prefixed.")
            continue
            
        new_name = f"{add_prefix} {old_name}"
        
        action.name = new_name
        renamed_count += 1
        
        print(f"	'{old_name}' -> '{new_name}'")
        
    print(f"--- Finished: Prefixed {renamed_count} Actions. ---")



def copy_retarget_actions_add_prefix(new_prefix: str) -> None:
    """
    Finds all Actions ending with a "Retarget", and creates a copy
    with a new name and prefix.
    "Retarget" keyword will be deleted.
    """
    # Use get_filtered_action_names with T-pose exclusion
    action_names = get_filtered_action_names(block_words=["t pose", "t-pose"], block_prefixes=[])
    all_actions = [bpy.data.actions[name] for name in action_names]
    
    search_keyword = "Retarget"
    # Compile regex patterns from the keyword for searching and removing
    # re.escape() handles special characters safely
    search_pattern = re.compile(r"\s*" + re.escape(search_keyword) + r"\s*$", flags=re.IGNORECASE)
    
    # Create a list first to avoid issues with modifying the collection while looping
    actions_to_copy = [act for act in all_actions if search_pattern.search(act.name)]
    
    if not actions_to_copy:
        print(f"No Actions found ending with the keyword '{search_keyword}' to copy.")
        return

    created_count = 0
    print("\n--- Copying Actions ---")

    for act in actions_to_copy:
        old_name = act.name
        
        # Get the base name by removing the keyword
        base_name = search_pattern.sub("", old_name).rstrip()
        
        # Create the new name using the prefix (case-sensitive)
        new_name = f"{new_prefix} {base_name}"
        
        # Copy the action and assign the new name
        new_act = act.copy()
        new_act.name = new_name
        
        print(f"	Created: '{new_act.name}' (from '{old_name}')")
        created_count += 1
        
    print(f"--- Finished: Created {created_count} new Actions. ---")


def copy_all_actions_add_prefix(prefix: str) -> None:
    # Use get_filtered_action_names with T-pose exclusion
    action_names = get_filtered_action_names(block_words=["t pose", "t-pose"], block_prefixes=[])
    actions_to_copy = [bpy.data.actions[name] for name in action_names]
    
    created_count = 0
    print(f"\n--- Copying all Actions and adding prefix '{prefix}' ---")

    for original_action in actions_to_copy:
        old_name = original_action.name
        new_name = f"{prefix} {old_name}"
        
        # Optional: Skip if a copy with this name already exists
        # Case-sensitive check for existing actions
        if new_name in bpy.data.actions:
            print(f"	Skipping '{old_name}', copy '{new_name}' already exists.")
            continue
            
        # Create the copy and assign the new prefixed name
        new_action = original_action.copy()
        new_action.name = new_name
        
        created_count += 1
        print(f"	Created: '{new_name}' (from '{old_name}')")

    print(f"--- Finished: Created {created_count} new Actions. ---")



def remove_word_from_actions(keyword_to_remove: str) -> None:
    """
    Finds all Actions with a specific keyword in their name and removes all 
    occurrences of that keyword, cleaning up any extra spaces.
    """
    # Use get_filtered_action_names with T-pose exclusion
    action_names = get_filtered_action_names(block_words=["t pose", "t-pose"], block_prefixes=[])
    all_actions = [bpy.data.actions[name] for name in action_names]
    
    # Find all actions that contain the keyword (case-insensitive)
    keyword_lower = keyword_to_remove.lower()
    actions_to_modify = [action for action in all_actions if keyword_lower in action.name.lower()]

    if not actions_to_modify:
        print(f"No Actions found with the keyword '{keyword_to_remove}'.")
        return

    modified_count = 0
    print(f"--- Removing '{keyword_to_remove}' from Action Names ---")

    for action in actions_to_modify:
        old_name = action.name
        
        # Case-insensitive replacement using regex
        pattern = re.compile(re.escape(keyword_to_remove), flags=re.IGNORECASE)
        name_without_keyword = pattern.sub('', old_name)
        
        # Clean up potential double spaces by splitting and re-joining
        new_name = " ".join(name_without_keyword.split())
        
        # Apply the new name
        action.name = new_name
        modified_count += 1
        
        print(f"	'{old_name}' -> '{new_name}'")
        
    print(f"--- Finished: Modified {modified_count} Actions. ---")



def get_filtered_action_names(block_words: List[str], block_prefixes: List[str], prefix: str = "") -> List[str]:
    """
    Gets a sorted list of action names, filtering out any that contain a blocked word
    or start with a blocked prefix (both case-insensitive). If `prefix` is provided,
    only actions whose names START with that prefix (case-insensitive) are kept.
    Note: block filters have higher priority than the positive prefix filter.
    """
    filtered_names = []

    lower_block_words = [w.lower() for w in block_words]
    lower_block_prefixes = [p.lower() for p in block_prefixes]
    lower_keep_prefix = prefix.lower()

    for action in bpy.data.actions:
        name = action.name
        nl = name.lower()

        # 1) block by words
        if any(w in nl for w in lower_block_words):
            continue
        # 2) block by prefixes
        if any(nl.startswith(p) for p in lower_block_prefixes):
            continue
        # 3) positive prefix filter (if provided)
        if lower_keep_prefix and not nl.startswith(lower_keep_prefix):
            continue

        filtered_names.append(name)

    return sorted(filtered_names)



def get_actions_by_prefix(prefix: str) -> List[str]:
    action_names = get_filtered_action_names(
        block_words=["t pose", "t-pose"],
        block_prefixes=[],
        prefix=prefix
    )
    print(f"Found {len(action_names)} action(s) starting with the prefix '{prefix}'.")
    return action_names



def rename_actions_replacing_word(term_from: str, term_to: str, is_prefix: bool = False) -> None:
    """
    Rename Actions by either:
      - prefix: if is_prefix=True, replace leading `term_from` with `term_to`
      - substring: if is_prefix=False, replace *all* occurrences of `term_from` with `term_to`

    Uses get_filtered_action_names with T-pose exclusions.
    Case-insensitive matching; Blender will uniquify on collisions.
    """
    if not term_from:
        tag = "rename_prefix" if is_prefix else "rename_replace"
        print(f"[{tag}] Empty term_from; nothing to do.")
        return

    # Gather actions (exclude T-pose variants)
    action_names = get_filtered_action_names(block_words=["t pose", "t-pose"], block_prefixes=[])
    all_actions = [bpy.data.actions[name] for name in action_names]

    changed = 0
    if is_prefix:
        tag = "rename_prefix"
        pat = re.compile(r'^' + re.escape(term_from), flags=re.IGNORECASE)
        for act in all_actions:
            old = act.name
            new = pat.sub(term_to, old, count=1)
            if new != old:
                act.name = new
                changed += 1
                print(f"[{tag}] '{old}' -> '{new}'")
    else:
        tag = "rename_replace"
        pat = re.compile(re.escape(term_from), flags=re.IGNORECASE)
        for act in all_actions:
            old = act.name
            new = pat.sub(term_to, old)
            if new != old:
                act.name = new
                changed += 1
                print(f"[{tag}] '{old}' -> '{new}'")

    print(f"[{tag}] Done. Renamed {changed} action(s).")


# O for original
# RM O for original with RM preserved (true original actually)

if __name__ == "__main__":
    print("")
    # 1
#    add_prefix_to_all_actions(add_prefix="O")
    # 2
#    copy_all_actions_add_prefix(prefix="RM")    
    # 3 - AFTER ROOT BAKED
#    copy_retarget_actions_add_prefix("SWSl")
    
    
    
    #######
    
    # dev
    
#    add_prefix_to_all_actions(add_prefix="Walk Combat")
#    remove_word_from_actions(keyword_to_remove = "root.")
#    remove_word_from_actions(keyword_to_remove = "|Unreal Take|Base Layer")
#    remove_word_from_actions(keyword_to_remove = "forward")
    rename_actions_replacing_word("left", "L")
    rename_actions_replacing_word("right", "R")