'''
This module must be attached to a child node of a scene to be used in the game, preferrably named
"SceneComponent". This module describes how the scene should be inserted in the Scene Root and
what does it need for communication with other scenes.
for more information on its use case, see scene_manager.gd
for more information on bridge_script, see brige_layer.gd
'''

class_name SceneComponent
extends Node

enum SCENE_TYPE {
	WORLDSPACE,
	UI
}

@export_group("Scene Loading")
@export var scene_type := SCENE_TYPE.WORLDSPACE
@export var bridge_script: Script = null # This contains the script for connecting scenes (like an API)
