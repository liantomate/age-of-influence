'''
Contains data to identify and generate a level
'''

class_name LevelData
extends Resource

@export var level_name: String = ""
@export var level_seed: int = 0

var height_data: PackedFloat32Array = []
