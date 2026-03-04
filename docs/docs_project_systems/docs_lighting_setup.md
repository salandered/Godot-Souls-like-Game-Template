# Shadow/lighting setup ☀️🌑 <!-- omit from toc -->

- [🥧 Light Baking](#-light-baking)
	- [Pre-bake Checklist](#pre-bake-checklist)
- [⚙️ Node settings](#️-node-settings)
	- [Mesh Instance Settings](#mesh-instance-settings)
	- [Light Settings](#light-settings)

## 🥧 Light Baking

### Pre-bake Checklist

Before baking:

1. **Check UV2:** Check mesh settings to ensure static meshes have UV2 (there is a project script that automates this).
1. **Scene Placement:** ⚠️ `LightmapGI` only affects nodes which are siblings or lower than itself.  
1. **Probes:** The less sure you are how baking will work, the _lower quality settings_ should be (`LightmapGI` properties). Otherwise it may be very slow or lead to crash.
1. **Save:** ⚠️ **Save your scene**. Baking may lead to Godot crash.

## ⚙️ Node settings

Note:

- Work in progress and should be considered as a baseline. Cases which require an alternative setup (aesthetics or optimization reasons) are common.
- Currently cover light baking settings as well, while sometimes you don't need it at all.

### Mesh Instance Settings

Settings for `MeshInstance3D` nodes.

| Object Type                                       | UV2      | GI Mode      | Cast Shadows   | Result                                                                                                       |
|---------------------------------------------------|----------|--------------|----------------|--------------------------------------------------------------------------------------------------------------|
| 🏠 **Static Environment**<br>(Walls, Floor)       | **Yes✅** | **Static**   | **On**/**Off** | Baked lights and shadows.                                                                                    |
| 💔**Breakable Static**<br>(Crates, Barrels)       | **No**   | **Dynamic**  | **On**         | Receives probe light. No baked shadow (safe to destroy).                                                     |
| 🔴 **Rigid Body**<br>(Movable Props)              | **No**   | **Dynamic**  | **On**         | Receives Probe Light. Shadow moves with object.                                                              |
| 💃**Character**<br>(Player, NPC)                  | **No**   | **Dynamic**  | **On**         | Receives Probe Light. Shadow moves with character.                                                           |
| Small props like rings, buttons                   | **No**   | **Disabled** | **Off**        | Can be all turned off as an optimization. Trade off: might start to stand out, like "glowing" in dark areas. |
| ⚔️ Weapon                                         | **No**   | **Dynamic**  | **On**         |                                                                                                              |
| Interactable<br>**Whole Chest**                   | **No**   | **Dynamic**  | **On**         | Simpler. Lighting is consistent between the lid and base.                                                    |
| _optional_<br>**Chest Base (Static)**             | **Yes✅** | **Static**   | **On**         | Optimized version. The base is baked into the world.                                                         |
| _optional_<br>**Chest Lid (Movable)**             | **No**   | **Dynamic**  | **On**         | Only lid is dynamic. Trade off: If Base and Lid use the same texture, the difference is noticeable.          |
| **Magic Health Orb**<br>(floating, pickable item) | **No**   | **Disabled** | **Off**        | Shadows - probably off.                                                                                      |
| 🌫️Fog (CPU Particles)                            | **No**   | **Disabled** | **Off**        | Safest is all off                                                                                            |
| ✨Sword Sparks (GPU Particles)                     | **No**   | **Disabled** | **Off**        | Safest is all off. Casting shadows is a waste of resources.                                                  |

### Light Settings

Settings for `Light3D` nodes.

By node type:

| Light Type                         | Bake Mode    | Shadow | Description                                                                                       |
|------------------------------------|--------------|--------|---------------------------------------------------------------------------------------------------|
| **DirectionalLight**<br>(Sun/Moon) | **Dynamic**  | **On** | Calculates real-time shadows for everything (static & dynamic). Bakes indirect bounce light only. |
| **Omni/Spot**<br>(Flashlight/Gun)  | **Disabled** | **On** | All real-time, no baking involved.                                                                |
| **Omni/Spot**<br>(Lantern on Wall) | **Static**   | **On** | Fully baked (shadows & light).                                                                    |

By node usage:

| **Light Role**                                     | **Bake Mode**    | **Shadow** | **Description**                                                          |
|----------------------------------------------------|------------------|------------|--------------------------------------------------------------------------|
| **Hero Light**<br>_(Key Spots, Player Path)_       | **Dynamic**      | **On**     | Looks cool but expensive.                                                |
| **Background Light**<br>_(Distant Lanterns)_       | **Static**       | **On**     | Optimization: baked into texture, no dynamic shadows. Zero runtime cost. |
| VIsual highlighting (like clue)                    | **Static**       | **On/Off** | Zero runtime cost                                                        |
| Particle Fog Light<br>Making smoke puffs look 3D. | Dynamic/Disabled | OFF        |                                                                          |
| Volumetric Fog Light<br>God rays / Beams           | Dynamic/Disabled | ON         |                                                                          |
