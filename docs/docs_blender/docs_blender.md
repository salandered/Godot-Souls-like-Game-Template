# Blender 🍊 <!-- omit from toc -->

- [Recommended blender addons](#recommended-blender-addons)
- [Instructions](#instructions)
	- [Texture baking](#texture-baking)
	- [Rigging fingers](#rigging-fingers)
	- [Root rotation: baking hips rotation to root bone](#root-rotation-baking-hips-rotation-to-root-bone)
	- [Auto collision](#auto-collision)
		- [Troubleshooting](#troubleshooting)

## Recommended blender addons

Some of them are not free.

**PolyQuilt** - <https://extensions.blender.org/add-ons/polyquilt-fork/?utm_source=blender-4.5.1-lts>

- good alternative for working with topology, while finicky
- in particular, helped me to learn about manual low retopology
- Edge Loop - can be helpful sometimes
- Killer feature: Smooth brush. Works like an alternative of Smooth Sculpt, but in Edit mode. Tender and reliable

**Import Mixamo - Root Motion** - <https://extensions.blender.org/add-ons/import-mixamo-root-motion/>

- necessary for working with Mixamo animations
- supports auto creation of Root bone and baking root motion to it from the hips
- make readable action names and bone names
- recently updated and probably supports baking root rotation (currently I use instruction from below)

**[BAM] AutoMat** <https://extensions.blender.org/add-ons/bam/>

- Powerful management of the materials in project
- I tested and 'adopted' only basic features like
  - batch material replacement
  - batch selection of meshes based on mat
  - seeing mat info while hovering mouse above the mesh

**Gizmo Pro** - <https://superhivemarket.com/products/gizmo-pro-addon-blender-2>

- more flexible gizmo than built-in one
- allows to use small gizmo on 3D cursor
- Luna is the most minimalistic option

**QoL:**

- **Drop It**- <https://andreasaust.gumroad.com/l/drop_it>
- **3D Cursor Plus** - <https://extensions.blender.org/add-ons/cursor-plus/>
- **Node preview** - <https://superhivemarket.com/products/node-preview>
  - (how is this not a blender built-in feature? may be they added in 5)
- **Node arrange** - <https://extensions.blender.org/add-ons/node-arrange/>

For texture baking I tried **SimpleBake** and **TexTools**.
Needs more testing. Also **QuickBaker** is probably good.

## Instructions

### Texture baking

- DO NOT use built-in blender baking.

### Rigging fingers

- switch to normal
- pivot point to active element
- select three finger parts (active is the closest to the wrist, not the tip) (phalanx)
- Scale to 0 by x: "S, X, 0"

Details: <https://youtu.be/dXElhdXgFD8?si=9EuM3ocMYxnd6wec&t=719>

Also about bone rotation: <https://youtu.be/ws8oWmBbo_s?si=DtTD83nsZRnEPjjP&t=428>

### Root rotation: baking hips rotation to root bone

This is needed for turn animations, like U-turn (turn 180)

1. copy `source anim` and name `result anim`
1. link armature and `result anim`
1. select **Edit mode** for armature
1. select `Hips` bone -> alt+P -> clear parent
1. **Pose mode** -> select `Root` -> copy **Rotation constraint** for bone.
   - target = Our armature and bone `Hips`
   - axis Z (only Z, no inverse).

  - World spaces for both (no inverted axis selected)

1. Bake action (`Root` still selected):

 - frames = anim frames,
 - checked: only selected bones, visual keying, clear constraints, overwrite curr action.
 - bake data: Pose.
 - Channel: all or rotation. By default was all and it worked

Validation: `Root` rotates according to animation. No crazy fast movement.
Anim works also as expected (global anim rotation could've been changed after alt P)

1. Parent `Hips` to `Root` (as they were)
     - **Edit mode** -> select `Hips`, select `Root` -> Ctrl+P -> Keep offset
1. **Pose mode** -> select `Hips`
1. Copy Rotation from `Root`, only Z! no inverse. Everything else defaulted.

Validation: animation should look as expected, no deviations at all.

1. Bake action (`Hips` still selected in **Pose mode**)

### Auto collision

[See docs_blender_auto_collision_workflow](docs_blender_auto_collision_workflow.md).

#### Troubleshooting

`source anim` animation (or any other animation) suddenly breaks

- It's not a problem with anim or armature.
- After playing animation with real ROOT ROTATION, root stucks in some specific position, which breaks other animations.
- just reset the pose before playing other animations on that armature.
- (the same as with root motion, but in that case the influence of prev anim is obvious, while here it looks scary)
