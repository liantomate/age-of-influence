'''
Contains data to identify and generate a level
'''

class_name LevelData
extends Resource

@export_group("General Data")
@export var level_name := ""
@export var level_size := Vector2i(100, 100)
@export var level_seed := 0

@export_group("Height Generation Data")
@export var height_frequency := 0.07
var height_data: PackedFloat32Array = []
