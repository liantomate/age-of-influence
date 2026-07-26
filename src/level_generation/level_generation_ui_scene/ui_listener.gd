extends Node

@export_group("UI Exports")
@export var level_name_input: LineEdit
@export var level_seed_input: LineEdit
@export var regenerate_preview_button: Button
@export var generate_level_button: Button

var bridge: LevelGenerationBridge

func _ready() -> void:
	var bridge_instance = SceneManager.bridge_layer.get_bridge_from_scene(get_parent())
	if bridge_instance is LevelGenerationBridge:
		bridge = bridge_instance
	
	if not bridge.level_path or bridge.level_path.is_empty():
		bridge.level_data = LevelData.new()
	
	level_name_input.connect("text_changed", _on_level_name_input_changed)
	level_seed_input.connect("text_changed", _on_level_seed_input_changed)
	
	regenerate_preview_button.connect("button_down", _on_regenerate_preview_button_pressed)
	generate_level_button.connect("button_down", _on_generate_level_button_pressed)

func _on_level_name_input_changed(value: String) -> void:
	if value.is_empty():
		bridge.level_data.level_name = "Untitled"
		return
	
	bridge.level_data.level_name = value

func _on_level_seed_input_changed(value: String) -> void:
	if not value.is_valid_int():
		level_seed_input.text = str(bridge.level_data.level_seed)
		level_seed_input.caret_column = level_seed_input.text.length()
		return
		
	bridge.level_data.level_seed = int(value)

func _on_regenerate_preview_button_pressed() -> void:
	pass

func _on_generate_level_button_pressed() -> void:
	bridge.emit_signal("level_generation_requested")
