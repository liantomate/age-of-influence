'''
This module is responsible for managing scene insertion and deletion, and is globally autoloaded
so it can be accessed by any module. It requires three layers (nodes) before it can be used: "UI",
"Worldspace", and "Bridge" layers.
for more information about layers, see: scene_component.gd
'''

extends Node

signal loading_started(loading_screen_path: String)
signal loading_progress(progress: float)
signal loading_finished

'''
Contains the possible execution of states with respect to the previous state
Delete: completely overrides the previous state (by removal)
Pause: pauses previous state execution but does not delete it
Overlay: both states run at the same time
'''
enum ExecutionMode {
	DELETE,
	PAUSE,
	OVERLAY 
}

'''
Represents an entire scene change request to be processed
'''
class SceneRequest:
	var scene_path: String
	var mode: ExecutionMode
	var loading_scene_path: String
	
	func _init(path: String, exec_mode: ExecutionMode, load_path: String):
		self.scene_path = path
		self.mode = exec_mode
		self.loading_scene_path = load_path

var _request_queue: Array[SceneRequest] = [] # To be processed requests
var _is_processing_queue: bool = false # For avoiding process collisions
var _state_stack: Array[Node] = []

# Number of "grouping" nodes per scene, in this case: State Components and UI
const _NUM_OF_SCENE_LAYERS := 2

var worldspace_layer: Node
var ui_layer: Node
var bridge_layer: BridgeLayer

func _ready() -> void:
	if get_child_count() > _NUM_OF_SCENE_LAYERS:
		_state_stack.append(get_child(_NUM_OF_SCENE_LAYERS))

'''
Appends a new scene for request with behavior depending on the Execution Mode
'''
func append_scene(scene_path: String, mode: ExecutionMode = ExecutionMode.DELETE, loading_scene_path: String = "") -> void:
	var request := SceneRequest.new(scene_path, mode, loading_scene_path)
	_request_queue.append(request)
	_process_queue()

'''
Removes the latest scene appended, activating it if it was previously paused
'''
func pop_scene() -> void:
	if _state_stack.size() <= 1:
		push_warning("Cannot pop the last remaining scene state!")
		return
		
	var top_scene = _state_stack.pop_back()
	top_scene.queue_free()
	await top_scene.tree_exited
	
	var previous_scene = _state_stack.back()
	if previous_scene:
		previous_scene.process_mode = PROCESS_MODE_INHERIT

'''
Processes requests available in _is_processing_queue one by one
'''
func _process_queue() -> void:
	if _is_processing_queue or _request_queue.is_empty():
		return
		
	_is_processing_queue = true
	var current_request = _request_queue.pop_front()
	await _execute_scene_change(current_request)
	_is_processing_queue = false
	
	_process_queue() # Process all if there are other requests

'''
Compiles handling of previous scene with respect to the new scene requested, managing processes
from modifying previous scene process to the addition of the new scene to its appropriate layer
'''
func _execute_scene_change(request: SceneRequest) -> void:
	_handle_previous_scene(request)
	
	var loading_instance: Node = _handle_loading_scene_instantiation(request)
	var new_scene: Node = await _handle_new_scene_loading(request)
	
	_handle_loading_scene_deletion(loading_instance)
	_handle_scene_layer(new_scene)
	
'''
Takes in the previous scene and handles it depending on the mode of the new one
'''
func _handle_previous_scene(requested_scene: SceneRequest) -> void:
	var current_scene: Node = _state_stack.back() if not _state_stack.is_empty() else null
	if not current_scene: 
		return
		
	match requested_scene.mode:
		ExecutionMode.DELETE:
			_state_stack.pop_back()
			current_scene.queue_free()
			await current_scene.tree_exited
		ExecutionMode.PAUSE:
			current_scene.process_mode = PROCESS_MODE_DISABLED
		ExecutionMode.OVERLAY:
			pass

'''
Handles the loading scene initialization. Returns the loading instane if successful, else null is returned
'''
func _handle_loading_scene_instantiation(requested_scene: SceneRequest) -> Node:
	var loading_instance: Node = null
	
	if requested_scene.loading_scene_path.is_empty():
		return null
		
	emit_signal("loading_started", requested_scene.loading_scene_path)
	var load_scene = load(requested_scene.loading_scene_path)
	if load_scene:
		loading_instance = load_scene.instantiate()
		ui_layer.add_child(loading_instance)
		
	return loading_instance

'''
Handles the loading of the new scene. Note that this will run for the duration of the loading,
emitting loading_progress signal for updates
'''
func _handle_new_scene_loading(requested_scene: SceneRequest) -> Node:
	var progress = []
	
	ResourceLoader.load_threaded_request(requested_scene.scene_path)
	while ResourceLoader.load_threaded_get_status(requested_scene.scene_path, progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		emit_signal("loading_progress", progress[0])
		await get_tree().process_frame 
	
	return ResourceLoader.load_threaded_get(requested_scene.scene_path).instantiate()
	
'''
Deletes the loading scene if the loading is finished, emitting a loading_finished signal afterwards
'''
func _handle_loading_scene_deletion(loading_instance: Node) -> void:
	if not loading_instance:
		return
	
	loading_instance.queue_free()
	emit_signal("loading_finished")

'''
Adds the new scene to its appropriate layer and appends it to the state stack. If the scene
provided is null, the operation will be ignored
'''
func _handle_scene_layer(new_scene: Node) -> void:
	if not new_scene:
		return
		
	var scene_components := new_scene.get_children()
	var is_a_scene := false
	for component in scene_components:
		if component is SceneComponent:
			is_a_scene = true
			
			match component.scene_type:
				SceneComponent.SCENE_TYPE.WORLDSPACE:
					worldspace_layer.add_child(new_scene)
				SceneComponent.SCENE_TYPE.UI:
					ui_layer.add_child(new_scene)
			
			break
	
	if not is_a_scene:
		return
	
	_state_stack.append(new_scene)
