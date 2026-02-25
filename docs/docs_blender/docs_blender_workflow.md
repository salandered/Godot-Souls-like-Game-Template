# Blender - Godot workflow 🍊🤖 <!-- omit from toc -->

- [File format](#file-format)
- [Collection exporters](#collection-exporters)
- [Exporter settings](#exporter-settings)
- [Materials](#materials)
	- ['Real life' materials](#real-life-materials)
		- [Problem: Grayscale Maps vs. GLB Spec](#problem-grayscale-maps-vs-glb-spec)
			- [Solution](#solution)
	- [Solid materials](#solid-materials)
	- [Sharing materials](#sharing-materials)
- [See also 📌](#see-also-)

**Blender version** - latest 4.x. Python scripts will be broken if switching to Blender 5.

## File format

File format - GLB (glTF 2.0)

## Collection exporters

Collection exporters are recommended to use.

- One Blender scene would be split into several collections, each one corresponding to separate GLB file. This makes exporting and then importing in Godot faster and more flexible.
- Exporter may have different settings, i.e collection with level does not have animation data, while character skeleton does.
- Such exporter are persistent, their settings are saved in a .blend file.

## Exporter settings

**Export path** - somewhere inside project assets folder, like this: [-assets-/GLB-level/](../-assets-/GLB-level).

**Apply Modifiers** - usually should be checked: they represent the 'final' state of the blender data.

**Flatten Object Hierarchy** - usually unchecked, that way collection hierarchy will be preserved in Godot node tree

## Materials

### 'Real life' materials

This sentence nicely describes the theory and what we try to support:
"You design a PBR material in Blender using the Principled BSDF node, which the exporter compiles into a GLB file by packing your textures into ORM format. Godot then imports this GLB file and unpacks the ORM to recreate material."

**Maps that we use**:

- Diffuse (albedo), Normal, Metallic and Roughness. For simplicity, only these maps are usually used.
- Displacement should not be used. Because of the low poly nature of assets, it is not relevant. Also hard on performance.

**Sources:** CC0 textures, Polyheaven, etc

#### Problem: Grayscale Maps vs. GLB Spec

It's common that CC0 PBR materials use separate grayscale images for Roughness and Metallic.
While glTF/GLB expects them to be packed into a single image (called ORM):

> glTF expects the metallic values to be encoded in the blue (B🔵) channel, and roughness to be encoded in the green (G🟢)

If you created material in blender using an addon like **NodeWrangler**, material is not following this convention.
Blender (quote) "attempts to adapt", and Godot creates a wrong Standard Material:

- Uses B🔵 channel of roughness image for `roughness` and G🟢 channel of metallic image for `metallic`.
- While roughness image comes in grayscale and has nothing to do with metallic, and metallic is a different image (if present at all)

See also [blender docs](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html#metallic-and-roughness).

##### Solution

As I see it, most robust way is to 'merge' Metallic and Roughness images (optionally Occlusion as well, as a R🔴 channel) using image editor like **Krita**. Then changing the material (shader graph) on the Blender side. This way we follow the spec and all is fine. But this is hard to automate: we need a script for merging images (probably can be done with **ImageMagick** tool, not **Krita**), also python script on Blender side which will rearrange the shader. Every new downloaded materials should be processed using this steps before working with it.

Much simpler solution is to make a fix on Godot side: using post import scripts. Script will make sure that resulting StandardMat3D will use them correctly. In particular, it searches for metallic image, which Godot ignores. Downside is that in the end we use and store two or three images instead of one.

Currently this approach is used in the project: see [material_reimport.gd](../_workflow/POST_import_scripts/material_reimport.gd).
This script also saves 'fixed' materials and reuses them later, if it sees the same setup for newly imported GLB.

### Solid materials

For flexibility between Blender and Godot use [Imphenzia PixPal](https://imphenzia.com/imphenzia-pixpal).
It allows using hundreds of color hues with properties like metallic or shiny, using the same material consisting of images. One mesh can still be using different colors.

Downside is that you can't use gradient colors, also color can'be changed in Godot, because color is tied to the UV map, which is set up in Blender.

Its shader logic is recreated in Godot using addon [gd-pixpal-tools-addon](https://github.com/Flynsarmy/gd-pixpal-tools-addon). This repo contains this addon since changed were made to it.  

Of course a standard Godot materials with solid `albedo` can be used, but then it wouldn't be a part of Blender-Godot workflow.

### Sharing materials

Post import script [material_reimport.gd](../_workflow/POST_import_scripts/material_reimport.gd) saves materials and then reuses them. That way shared material library is naturally being maintained.

Another option is to do it manually. Simple example:

- Import two GLBs - **rock.glb** and **cave.glb**
- Extract shared material **rock_mat.tres** from **rock.glb**
  - Advanced Import Settings -> Extract Materials -> Save to `res://materials/shared/`
  - Material is now external and won't be overwritten on reimport
- Point cave.glb at the same material
  - Advanced Import Settings -> Find matching mat slot -> Use External → Set path to `res://materials/shared/rock_mat.tres`
  - Click Reimport (important to do!)

Verification

- Instance both scenes in editor
- Edit rock_mat.tres → both meshes update instantly

Note: Such materials will be ignored by `material_reimport.gd`, i.e manual sharing and mat set up has higher priority.

## See also 📌

Many ideas and practices were adopted from this read: <https://studio.blender.org/blog/our-workflow-with-blender-and-godot/>
