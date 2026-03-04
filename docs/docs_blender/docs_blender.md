# Blender 🍊 <!-- omit from toc -->

- [Blender - Godot workflow 🍊💙](#blender---godot-workflow-)
- [🧩 Recommended blender addons](#-recommended-blender-addons)
- [✍️ Instructions](#️-instructions)
	- [Texture baking](#texture-baking)
	- [Rigging fingers](#rigging-fingers)
	- [Root rotation: baking hips rotation to root bone](#root-rotation-baking-hips-rotation-to-root-bone)
	- [Weight painting tips](#weight-painting-tips)
	- [See also](#see-also)
- [👨‍🔧 Troubleshooting](#-troubleshooting)

## Blender - Godot workflow 🍊💙

> [!NOTE]
> See docs [here](docs_blender_godot_workflow.md)

## 🧩 Recommended blender addons

Some of them are paid.

**PolyQuilt** - <https://extensions.blender.org/add-ons/polyquilt-fork/?utm_source=blender-4.5.1-lts>

- good alternative for working with topology, while finicky
- in particular, helped me to learn about manual low poly retopology
- Edge Loop - can be helpful
- Killer feature: Smooth brush. Works like a Smooth brush in Sculpt, but in Edit mode. Tender and reliable

**Import Mixamo - Root Motion** - <https://extensions.blender.org/add-ons/import-mixamo-root-motion/>

- necessary for working with Mixamo animations
- supports auto creation of Root bone and baking root motion to it from the hips
- make readable action names and bone names
- recently updated and probably supports baking root rotation (currently I use the instruction below)

**[BAM] AutoMat** <https://extensions.blender.org/add-ons/bam/>

- Powerful management of the materials in project
- I currently use only basic features like
  - batch material replacement
  - batch selection of meshes based on mat
  - seeing mat info while hovering mouse above the mesh

**Gizmo Pro** - <https://superhivemarket.com/products/gizmo-pro-addon-blender-2>

- more flexible gizmo than a built-in one
- allows to use small gizmo on a 3D cursor
- Luna is the most minimalistic option

**Rokoko (Animation Retarget)** - https://support.rokoko.com/hc/en-us/articles/4410463492241-How-to-install-the-Blender-plugin

- Plugin which is used for Rokoko motion capture.
- Somehow it has Rokoko agnostic feature for animation retargetting, which we use,

**QoL:**

- **Drop It**- <https://andreasaust.gumroad.com/l/drop_it>
- **3D Cursor Plus** - <https://extensions.blender.org/add-ons/cursor-plus/>
- **Node preview** - <https://superhivemarket.com/products/node-preview>
  - (how is this not a blender built-in feature? may be they added in 5)
- **Node arrange** - <https://extensions.blender.org/add-ons/node-arrange/>

For texture baking I tried **SimpleBake** and **TexTools**.
Needs more testing. Also **QuickBaker** is probably good.

## ✍️ Instructions

### Texture baking

⚠️ Do not use built-in blender baking. Use addons.

### Rigging fingers

- switch to `normal`
- pivot point to `active element`
- select three finger parts (active is the closest to the wrist, not the tip) (phalanx)
- Scale to 0 by x: shortcut is: **"S, X, 0"**

ℹ️ Details: https://youtu.be/dXElhdXgFD8?si=9EuM3ocMYxnd6wec&t=719

Also about bone rotation: https://youtu.be/ws8oWmBbo_s?si=DtTD83nsZRnEPjjP&t=428

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

**Validation**: `Root` rotates according to animation. No crazy fast movement.
Anim works also as expected (global anim rotation could've been changed after alt P)

1. Parent `Hips` to `Root` (as they were)
     - **Edit mode** -> select `Hips`, select `Root` -> Ctrl+P -> Keep offset
2. **Pose mode** -> select `Hips`
3. Copy Rotation from `Root`, only Z! no inverse. Everything else defaulted.

**Validation**: animation should look as expected, no deviations at all.

1. Bake action (`Hips` still selected in **Pose mode**)
   - similar to the first bake

### Weight painting tips

Description to come

### See also

See also instructions inside [Blender-Godot workflow docs](docs_blender_godot_workflow.md)

## 👨‍🔧 Troubleshooting

animation (or any other animation) suddenly breaks when working with root rotation

- It's not a problem with anim or armature.
- After playing animation with root rotation, root stucks in some specific position, which breaks other animations.
- just reset the pose before playing other animations on that armature.
- (same idea as with root motion, but in that case the influence of prev anim is obvious, while here it looks scary)
