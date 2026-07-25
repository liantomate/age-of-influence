'''
This module handles the "Bridge layer" from the Scene Root, handling data that must be shared between
other scene root layers like "UI" and "Worldspace", removing the clutter of them having to communicate
to each other
'''

class_name BridgeLayer
extends Node

var bridges: Dictionary[Script, SceneBridge] = {}

'''
Checks for the bridge of a scene and returns a corresponding node instance of it. It returns null for
invalid scenes or bridges. If a bridge has already been created, it simply returns that instance, else
a new bridge is created
'''
func get_bridge_from_scene(scene: Node) -> SceneBridge:
	var script = _get_bridge_script_from_scene(scene)
	
	if not script:
		return null
	
	if bridges.has(script):
		return bridges[script]
	
	var instance = script.new()
	bridges[script] = instance
	add_child(instance)
	return instance

'''
Checks for the bridge of a scene and attempts to remove the instance from the tree and the dictionary.
It returns true for a successful deletion while false for not (not a scene / invalid bridge / no instance)
'''
func remove_bridge_from_scene(scene: Node) -> bool:
	var script = _get_bridge_script_from_scene(scene)
	
	if not script:
		return false
	
	if not bridges.has(script):
		return false
	
	remove_child(bridges[script])
	return true

'''
Takes a scene and checks whether it has a SceneComponent or not, from that, it returns the bridge_script
defined in the SceneComponent. It returns the script for a successful operation while null for not
(null scene / no SceneComponent)
'''
func _get_bridge_script_from_scene(scene: Node) -> Script:
	if scene == null:
		return null
	
	var components := scene.get_children()
	var scene_component: SceneComponent = null
	var is_a_scene = false
	for component in components:
		if component is SceneComponent:
			is_a_scene = true
			scene_component = component as SceneComponent
			break
	
	if not is_a_scene:
		return null
	
	return scene_component.bridge_script
