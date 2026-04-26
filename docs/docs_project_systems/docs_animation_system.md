
# Animation Framework 🟣 <!-- omit from toc -->

- [Intro](#intro)
- [Animation Manager](#animation-manager)
- [Current Implementations](#current-implementations)
	- [Player Implementation](#player-implementation)
		- [How it works](#how-it-works)
		- [Blending](#blending)
		- [Bone Masks](#bone-masks)
		- [Optimization](#optimization)
- [👥 Overlaying](#-overlaying)
	- [Overlay Configuration](#overlay-configuration)
	- [Technical Implementation](#technical-implementation)
- [🌱 Root Motion](#-root-motion)
	- [Main character](#main-character)
	- [Enemy (NPC) Implementation](#enemy-npc-implementation)
	- [Simple Entities](#simple-entities)

> [!NOTE]
> See also [docs_animation_tracks.md](docs_animation_tracks.md)

## Intro

A transparent and configurable animation system built on Godot’s `SkeletonModifier3D`.

## Animation Manager

Most of the interaction with the framework happens through the `BaseAnimatorManager` interface.

Manager provides a facade for working with different animation system implementations.

Manager depends on animation container `BaseAnimContainer`. Container should be initialized in advance with all supported animations (see also `AnimationData`).

Key functions:

- `set_anim_to_play(anim_id: StringName, blend_for: float, start_time_offset: float)`: plays new animation
  - `anim_id` is unique across the system and should exist in animation container.
  - `blend_for` blending duration
  - `start_time_offset` offset of the animation (e.g.: playing run animation not from the first frame)
- `set_global_speed_scale(new_scale: float)`: Adjusts the playback speed globally.

## Current Implementations

Under the manager facade, there are currently three specific implementations:

- **Player:** The most complex one, designed for the main character.
- **NPC:** Used for enemies or friendly characters.
- **Simple Entities:** Used for animatable objects that do not have a skeleton (e.g., complex interactive props).

### Player Implementation

Is based `SkeletonModifier` instead of the `AnimationPlayer`. This provides a greater control over current playbacks and blending progress.
For example, API includes:

- `get_prev_anim_time_spent`
- `get_curr_blend_percentage`

#### How it works

The system manually calculates and applies bone poses every frame.

At a low level, the system separates animation data from the actual playback state.

- It uses the `AnimPlayback` class to track the current animation's state, storing the `time_spent` and any starting offsets.
- Every process tick, the system updates the playback, recalculates blend values, and processes the skeleton update.
- During the skeleton update, it calculates position and rotation for each bone based on the animation data

#### Blending

System maintains several active `AnimPlayback` states simultaneously, along with blend playbacks that tie two animation states together.

When updating the skeleton, it calculates the transform for each active playback and interpolates the results based on the current blend percentages.

Maximum supported depth is 4 concurrent animations (the current animation plus up to three interrupted previous animations).

#### Bone Masks

The system uses a `bone_mask` array to define which bones should be updated. This allows you to assign different masks to isolate animations to specific body parts.

#### Optimization

Calculating bone paths dynamically every frame is computationally expensive.

The framework calculates and caches all bone track paths into a dictionary (`_bone_idx_to_track`) during initialization.

## 👥 Overlaying

Overlays are used to play a specific animation on top of the current base animation.
The API for managing overlays is located within `BaseSkeletonAnimatorManager`.

- `set_overlay_anim(anim_id, overlay_config, start_time_offset)`
- `force_stop_overlay(fade_out_duration)`

Overlays are used to play a specific animation without interrupting the underlying state machine.

- Examples: Quick, non-disruptive actions like weapon switching or a subtle hurt reaction.
- Compare with: Heavy impacts like pushbacks. These require a dedicated state and root motion calculations.

### Overlay Configuration

When triggering an overlay, you pass an `OverlayConfig` object.

- **`Weight` (`global`, `hips`)**: The blend influence. The `hips` value allows for specific tweaks (e.g. to prevent the upper-body overlay from awkwardly overriding character's locomotion states or root position).
- **`BlendConfig`**: Controls the transition timing using `fade_in`, `fade_out`, and `hold` times (in seconds). This class provides different utilities to auto-calculate its parameters based on the animation duration.
- **`_speed_scale`**: Adjusts the playback speed specifically for the overlay animation.
- **`_bone_mask`**: Array of bones to be influence by the overlay.

### Technical Implementation

It is similar to the `PlayerModifierAnimator`. It is built on a `SkeletonModifier`, maintains its own animation playbacks, and calculates bone transforms directly from the animation data.

Because overlay animations are intended to be short and rarely overlap with each other, depth blending of two max is supported.

## 🌱 Root Motion

Root motion extracts movement and rotation directly from the animation data. The implementation details vary depending on the entity type.

### Main character

For the player, the animation manager exposes the `get_root_velocity` and `get_root_rotation` functions. Under the hood is is maintained by the `PlayerRootAnimator`.

In practice, you should usually use the higher-level API provided by the `PlayerMovement` class:

- `move_with_root`
- `apply_root_rotation`

### Enemy (NPC) Implementation

Enemies use a much simpler animation manager implementation. The API is `get_root_motion_position` and it relies on the built-in Godot `AnimationPlayer.get_root_motion_position` method.

The `EnemyMovement` class provides a more useful, high-level API for handling NPC root motion.

### Simple Entities

For simple entities and non-skeleton animators, root motion is not applied at all.
