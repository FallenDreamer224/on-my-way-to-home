extends SceneTree
## Dependency-free integration checks. Run after the editor import pass.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SETTINGS: Resource = preload("res://resources/config/development_settings.tres")

var _failures: Array[String] = []
var _checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_check(ProjectSettings.get_setting("application/config/name") == "On My Way to Home", "Project name")
	_check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/app_root.tscn", "Application menu entry scene")
	_check(ProjectSettings.get_setting("display/window/size/viewport_width") == 960, "Viewport width")
	_check(ProjectSettings.get_setting("display/window/size/viewport_height") == 540, "Viewport height")
	_validate_inputs()
	_check(ProjectSettings.get_setting("display/window/stretch/mode") == "viewport", "Viewport stretch")
	_check(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep", "Preserved aspect")
	_check(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "Integer scaling")
	_check(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "Nearest filtering")
	_check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Compatibility renderer")
	_check(TranslationServer.get_locale().begins_with("en"), "English startup locale")
	var project_config: ConfigFile = ConfigFile.new()
	_check(project_config.load("res://project.godot") == OK, "Readable project configuration")
	_check(not project_config.has_section_key("physics", "3d/physics_engine"), "No legacy physics override")
	_check(SETTINGS.is_active() == OS.is_debug_build(), "Development build gate")
	_validate_resources("res://scenes")
	_validate_resources("res://scripts")
	_validate_resources("res://resources")

	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_validate_native_nodes(main)
	for path: String in ["Systems", "World/Terrain", "World/Entities/Players", "World/Entities/NPCs", "World/Entities/Buildings", "World/Entities/Props", "CameraRig/Camera2D", "UI/GameHUD"]:
		_check(main.has_node(path), "Integration point: " + path)
	var entities: Node2D = main.get_node("World/Entities") as Node2D
	_check(entities.y_sort_enabled, "Entity Y-sorting")
	for child: Node in entities.get_children():
		var category: Node2D = child as Node2D
		_check(category != null and category.y_sort_enabled, "Category Y-sorting: " + child.name)
		_check(category.position == Vector2.ZERO and category.scale == Vector2.ONE, "Category coordinate basis: " + child.name)
	var camera: Camera2D = main.get_node("CameraRig/Camera2D") as Camera2D
	_check(root.get_camera_2d() == camera, "Active native 2D camera")
	_check(camera.zoom == Vector2(2, 2) and not camera.position_smoothing_enabled, "Player camera at 2x without smoothing")
	var ui: CanvasLayer = main.get_node("UI") as CanvasLayer
	_check(not ui.follow_viewport_enabled, "Screen-space UI")
	var screen: GameHUD = main.get_node("UI/GameHUD") as GameHUD
	_check(screen.visible and screen.development_badge.visible == OS.is_debug_build(), "Game HUD always visible; development badge respects build gate")
	_check(screen.size == Vector2(960, 540), "UI fills logical viewport")
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		_check(image.save_png("res://tests/output/foundation.png") == OK, "Save visual capture")
		await RenderingServer.frame_post_draw
		var next_image: Image = root.get_texture().get_image()
		_check(image.get_data() == next_image.get_data(), "Consecutive stationary render frames stable")
	main.queue_free()
	await process_frame

	var disabled: Resource = SETTINGS.duplicate()
	disabled.set("enabled", false)
	await _check_hidden_screen(disabled, "Disabled development configuration")
	var hidden: Resource = SETTINGS.duplicate()
	hidden.set("show_development_screen", false)
	await _check_hidden_screen(hidden, "Hidden development screen")
	await _check_hidden_screen(null, "Missing development configuration")

	if _failures.is_empty():
		print("PASS: %d foundation checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("FAIL: %d of %d foundation checks" % [_failures.size(), _checks])
		quit(1)


func _check_hidden_screen(settings: Resource, description: String) -> void:
	var main: Node = MAIN_SCENE.instantiate()
	main.set("development_settings", settings)
	root.add_child(main)
	await process_frame
	var screen: GameHUD = main.get_node("UI/GameHUD") as GameHUD
	_check(screen.visible and not screen.development_badge.visible, description + " hides diagnostics while preserving game HUD")
	main.queue_free()
	await process_frame


func _validate_resources(directory: String) -> void:
	var access: DirAccess = DirAccess.open(directory)
	_check(access != null, "Readable resource directory: " + directory)
	if access == null:
		return
	for filename: String in access.get_files():
		if filename.get_extension() in ["gd", "tscn", "tres"]:
			var path: String = directory.path_join(filename)
			var resource: Resource = load(path)
			_check(resource != null, "Load resource: " + path)
			if resource is Script:
				_check((resource as Script).can_instantiate(), "Compiled script: " + path)
			elif resource is PackedScene:
				var instance: Node = (resource as PackedScene).instantiate()
				_check(instance != null, "Instantiate scene: " + path)
				if instance != null:
					instance.free()
	for child: String in access.get_directories():
		_validate_resources(directory.path_join(child))


func _validate_native_nodes(node: Node) -> void:
	_check(not node is Node3D, "Native 2D hierarchy: " + str(node.get_path()))
	_check(not node is AudioStreamPlayer and not node is AudioStreamPlayer2D, "No audio nodes: " + str(node.get_path()))
	for child: Node in node.get_children():
		_validate_native_nodes(child)


func _validate_inputs() -> void:
	var expected_keys: Dictionary[String, int] = {
		"player_move_up": KEY_W, "player_move_down": KEY_S,
		"player_move_left": KEY_A, "player_move_right": KEY_D,
		"mode_switch": KEY_TAB, "camera_pan_up": KEY_UP,
		"camera_pan_down": KEY_DOWN, "camera_pan_left": KEY_LEFT,
		"camera_pan_right": KEY_RIGHT, "inventory_toggle": KEY_I,
		"game_pause": KEY_ESCAPE,
	}
	var expected_buttons: Dictionary[String, int] = {
		"interact_primary": MOUSE_BUTTON_LEFT, "interact_secondary": MOUSE_BUTTON_RIGHT,
		"camera_zoom_in": MOUSE_BUTTON_WHEEL_UP, "camera_zoom_out": MOUSE_BUTTON_WHEEL_DOWN,
	}
	var bindings: Array[String] = []
	for action: String in expected_keys.keys() + expected_buttons.keys():
		_check(InputMap.has_action(action), "Configured action: " + action)
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if action == "interact_primary":
			_check(events.size() == 2, "Primary action retains mouse binding plus keyboard interaction")
			var interaction_key: InputEventKey = events[1] as InputEventKey if events.size() == 2 else null
			_check(interaction_key != null and interaction_key.physical_keycode == KEY_E, "Primary interaction uses remappable E")
			events = [events[0]]
		_check(events.size() == 1, "Single initial binding: " + action)
		if events.size() != 1:
			continue
		var event: InputEvent = events[0]
		var signature: String = ""
		if action in expected_keys:
			var key: InputEventKey = event as InputEventKey
			_check(key != null and key.physical_keycode == expected_keys[action], "Key binding: " + action)
			if key != null:
				signature = "key:%d" % key.physical_keycode
		else:
			var button: InputEventMouseButton = event as InputEventMouseButton
			_check(button != null and button.button_index == expected_buttons[action], "Mouse binding: " + action)
			if button != null:
				signature = "mouse:%d" % button.button_index
		_check(signature not in bindings, "Unique game binding: " + action)
		bindings.append(signature)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
