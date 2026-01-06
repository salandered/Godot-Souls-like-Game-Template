
# MAIN INFO
- source of truth are LICENSE files provided with a software or asset packs
- if not such file provided, add one with the info found anythere on the authors web sites
	- example: julio sillet
- ATTRIBUTION file compiles all this licenses and additional info (like logo or links)
	- it is used in the credits 
	- ATTRIBUTION it is not a source of truth, since it compiles LICENSE files into one
	  BUT! if license is like CC-BY, it requires the 'appropriate credit' ('BY' part)
	  so dont forget to add such things


# LICENSE vs ATTRIBUTION tldr
File System (LICENSE files): Protects YOU (proves you have the right to use it).
Attribution List (ATTRIBUTION.md): Protects the AUTHOR (gives them the fame/exposure they asked for).


# CC BY which came without LICENSE file
just the attribution text is fine.

The CC-BY 4.0 license allows you to link to the license URL instead of providing the full legal text file, as long as it is "reasonable to the medium." In digital games, a clickable link in your credits is the standard reasonable method.


# MIT vs CC BY

The main difference comes down to what they were built to protect.
* MIT is built for Code.
* CC BY is built for Media (Art, Music, Text, Models).
both say "You can use this for free if you credit me," but some major differences
MIT vs CC BY 
Best For | Plugins, Scripts, Engine Code | Textures, Models, Sounds, Wikis
Attribution Style | Hidden: Keep the LICENSE file in the folder |Visible: Show the author's name in the UI/Credits.
Patent Rights | Yes: Grants users the right to use patents. | No: Explicitly does not grant patent rights
DRM / Encryption | Allowed: You can lock your code up tight. | Restricted: You cannot add DRM that stops people from ripping the asset out.

# cc0
- u can do whatever u want. Consider populating ATTRIBUTION with kinda this:
```
## Community Assets & Special Thanks
This game uses various open-source shaders, scripts, and plugins from the Godot community. 
While many are CC0/Public Domain, we would like to thank the creators:
* **Shaders:** Code snippets adapted from Shadertoy authors, [Plugin Author Name], and GodotShaders.com contributors.
* **Plugins:** [Plugin Name] by [Author] (License included in plugin folder).
```
