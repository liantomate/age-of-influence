class_name LevelGenerator
extends Node

@onready var scene_component := $"../SceneComponent"

var bridge: LevelGenerationBridge = null
var level_data: LevelData = null

func _ready() -> void:
	var bridge_instance = SceneManager.bridge_layer.get_bridge_from_scene(get_parent())
	if bridge_instance is LevelGenerationBridge:
		bridge = bridge_instance

'''
This function combines private functions of this module to generate the level from
LevelData in a step-by-step process
'''
func generate_level() -> void:
	_initialize_data()
	_initialize_arrays()
	
	_generate_height_data()

func _initialize_data() -> void:
	level_data = bridge.level_data
	if level_data == null:
		level_data = LevelData.new()

func _initialize_arrays() -> void:
	level_data.height_data = PackedFloat32Array()
	level_data.height_data.resize(level_data.level_size.x * level_data.level_size.y)

func _generate_height_data() -> void:
	var height_noise := FastNoiseLite.new()
	height_noise.seed = level_data.level_seed
	height_noise.frequency = level_data.height_frequency
	
	for y in range(level_data.level_size.y):
		for x in range(level_data.level_size.x):
				var index := x + y * level_data.level_size.x
				level_data.height_data[index] = height_noise.get_noise_2d(x, y)
