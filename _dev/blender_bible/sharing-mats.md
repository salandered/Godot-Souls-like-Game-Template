
## UPD
after creating post import scripts this info may be out of date

## Sharing Materials Between GLB Files
# Setup

Import both GLBs - Drop rock.glb and cave.glb into project
Extract shared material from rock.glb

Double-click rock.glb → Advanced Import Settings
Actions → Extract Materials → Save to res://materials/shared/
Rename extracted file to something stable (e.g., water_rocks.tres)
Material now external and won't be overwritten on reimport


Point cave.glb at the same material

Double-click cave.glb → Advanced Import Settings → Materials tab
Select the matching material slot
Check Use External → Set path to res://materials/shared/water_rocks.tres
Click Reimport


Verification

Instance both scenes in editor
Edit water_rocks.tres → both meshes update instantly
