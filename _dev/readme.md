

## Folder structure
After some time this emerged:
	containers/
	systems/
	entities/
	
system is what u call 'service'
container is more like 'repository', but at least for now they all read only
(u can call them registry as well)
entities is like main scenes. 


## Trooubleshooting
Godot ignores undo for some oprations, like with working with file system
Case: u added marker to animation, u moved file, u want to undo moving file
Result: marker deleted and u have no idea about it
Solution: Make history tab visible in godot editor and be carefult with ctrl Z


## Misc
this is like tenth readme i wrote, need to merge it all together


ERROR: Unable to open file: res://.godot/imported/wZZNl7ooWl.png-89aee342f0b8c84824800b901ab32938.ctex.
   at: (scene/resources/compressed_texture.cpp:41)
ERROR: Unable to open file: res://.godot/imported/wZZNl7ooWl.png-89aee342f0b8c84824800b901ab32938.ctex.
   at: (scene/resources/compressed_texture.cpp:41)