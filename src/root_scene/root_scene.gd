extends Node

@export_group("Layer Exports")
@export var ui_layer: Node
@export var worldspace_layer: Node
@export var bridge_layer: BridgeLayer

@export_group("Scene Exports")
@export_file_path(".tscn") var default_scene: String

func _ready() -> void:
	SceneManager.ui_layer = ui_layer
	SceneManager.worldspace_layer = worldspace_layer
	SceneManager.bridge_layer = bridge_layer

	SceneManager.append_scene(default_scene)
