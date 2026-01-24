# Hard Tissue Game Demo

## 📖 Description
A souls-like third person game demo made with Godot 4.5 and Blender.


## Key systems
Custom Animation Engine: A transparent and configurable animation system built on Godot’s SkeletonModifier3D. It supports animation blending; animation overlays; root motion/rotation, and bone masks allowing animations to play on a specific body part.

Directory: `logic/c_systems/anim_manager/`

Souls-like Camera: A composite multi-node camera system featuring custom-written collision detection and smoothing. It supports smooth target-locking and simulates physical inertia when following the player.

Hierarchical AI System: A boss enemy driven by a Hierarchical State Machine (HSM) managing over 30 states. The nested structure allows for behaviors like different phases and randomized attack combos drawn from a pool of moves.

Dynamic Sound Design: An audio framework featuring an animation-sync system that attaches SFX to specific frames of any animation (used for all character states and interactables). It also includes a background sound shuffler for environmental tracks and music themes, and audio zones to create a dynamic soundscape.

Rendering Optimization: Performance tuning using optimized materials, baked lighting (Lightmaps), Occlusion Culling and so on.

Automated Art Pipeline & Asset Integration: A seamless Blender-to-Godot workflow using GLB files and PBR standards, which uses custom post-import scripts that auto set ups collision shapes and material inventory (like categorizing using keywords, ORM texture setup, deduplication)

Core Architecture & Tooling: Logging System with log levels, filters and auto formatting; and Validation Framework to enforce initialization contracts for custom classes, prevents silent failures and ensures data integrity.

Art: Hand crafted levels, characters, props, interactable and breakable objects. Different lighting setups with fog types and particle systems, plus a dynamic weather system. CC0 3D assets were mostly used as a base but all underwent low-poly retopology, UV unwrapping and rigging (for characters) to ensure a consistent art style


### Key Technical Systems

* **Custom Animation Modifier:** Implements a custom `SkeletonModifier3D` to handle complex animation blending and time-dilation effects efficiently.
	* *Location:* `scripts/animation/modifier_animator.gd`
* **State-Based Camera System:** A robust camera controller handling collision, smoothing, and state switching (Locked/Free).
	* *Location:* `scripts/camera/fancy_camera.gd`

---

## 🛠️ How to Download & Setup

### Prerequisites
* **Godot Engine:** Version **[Insert Version, e.g., 4.3]** or higher.
* [Optional: Git LFS if you have large assets]

### Installation Steps
1.  **Clone the Repository:**
	
		git clone [YOUR_REPO_LINK_HERE]

2.  **Open in Godot:**
	* Launch the Godot Editor.
	* Click **Import**.
	* Navigate to the cloned folder and select the `project.godot` file.
	* Click **Import & Edit**.

---

## 📦 How to Export (Win Build)
To generate a standalone executable of the demo:

1.  Open the project in the Godot Editor.
2.  Go to **Project** -> **Export...** in the top menu.
3.  **Add a Preset:**
	* Click **Add...** at the top and select your target platform (Windows, macOS, or Linux).
	* *Note: If you haven't installed export templates, Godot will prompt you to download them.*
4.  **Configure Settings:**
    * Ensure **Export Path** is set to a valid folder (e.g., `builds/game.exe`).
    * Leave other settings at default for this demo.
5.  **Build:**
    * Click **Export Project** at the bottom of the window.
    * Uncheck "Export With Debug" if you want a release build (faster performance), or keep it checked if you want the console/profiler available.

---

## License
See LICENSE.md
