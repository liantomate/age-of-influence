'''
Shares resource between LevelGenerationScene with LevelGenerationUIScene
'''

class_name LevelGenerationBridge
extends SceneBridge

signal level_generation_requested

var level_path: String = ""
var level_data: LevelData = null
