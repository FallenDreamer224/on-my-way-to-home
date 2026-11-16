extends SceneTree
## Real application/window checks plus explicitly offscreen presentation-size simulations.
const OUTPUT: String = "res://tests/output/phase_0_9_1/"
const SIZES: Array[Vector2i] = [Vector2i(960,540), Vector2i(1280,720), Vector2i(1366,768), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(2560,1440), Vector2i(3440,1440)]
var checks: int = 0
var failures: PackedStringArray = []
var capture: bool = false
var settings: AppSettings

func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label)
func settle(count: int = 6) -> void:
	for i: int in count: await process_frame
func key(code: Key, alt: bool = false) -> void:
	for down: bool in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.alt_pressed = alt
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await settle()
func click(control: Control) -> void:
	var point: Vector2 = root.get_final_transform() * control.get_global_transform_with_canvas() * (control.size / 2)
	for down: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await settle()
func photo(name: String, physical: bool = false) -> void:
	if not capture: return
	if physical:
		root.grab_focus()
		await settle(12)
	await RenderingServer.frame_post_draw
	var image: Image = DisplayServer.screen_get_image(root.current_screen) if physical else root.get_texture().get_image()
	check(image != null and not image.is_empty(), "Native image available: " + name)
	if image != null and not image.is_empty(): check(image.save_png(OUTPUT + name + ".png") == OK, "Capture " + name)
func simulate(size: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.size = Vector2(size)
	viewport.add_child(black)
	var image := TextureRect.new()
	image.texture = root.get_texture()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var rect: Rect2 = AppSettings.presentation_rect(size)
	image.position = rect.position
	image.size = rect.size
	viewport.add_child(image)
	await settle()
	await RenderingServer.frame_post_draw
	var rendered: Image = viewport.get_texture().get_image()
	var source: Image = root.get_texture().get_image()
	check(rendered.get_size() == size, "Native offscreen dimensions " + str(size))
	for point: Vector2i in [Vector2i(100,100), Vector2i(480,270), Vector2i(730,400)]:
		var sample: Vector2i = Vector2i((rect.position + (Vector2(point) + Vector2(0.5,0.5)) * rect.size / Vector2(AppSettings.BASE_SIZE)).floor())
		check(rendered.get_pixelv(sample).is_equal_approx(source.get_pixelv(point)), "Nearest source-pixel sample " + str(size) + " / " + str(point))
	if size.x == 3440:
		check(rendered.get_pixel(0,720) == Color.BLACK and rendered.get_pixel(3439,720) == Color.BLACK, "Ultrawide has symmetric pillarboxes")
	if capture: check(rendered.save_png(OUTPUT + "simulated_%dx%d.png" % [size.x,size.y]) == OK, "Save native-size simulation")
	viewport.queue_free()
	await settle()
func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var original: AppSettings = AppSettings.shared()
	var original_topmost: bool = root.always_on_top
	if DisplayServer.get_name() != "headless":
		# Test-only foreground capture; do not change native flags during a fullscreen cycle.
		root.always_on_top = true
		root.grab_focus()
	settings = AppSettings.new(OUTPUT + "display_settings.cfg")
	settings.set_display(false,1,true)
	settings.set_interface(1,false,true)
	AppSettings.replace_shared(settings)
	check(InputMap.action_get_events(&"display_fullscreen_toggle").size() == 2, "One fullscreen action with F11 and Alt+Enter")
	AppSettings.ensure_interface_actions()
	check(InputMap.action_get_events(&"display_fullscreen_toggle").size() == 2, "Repeated initialization does not duplicate shortcuts")
	check(not settings.rebind(&"inventory_toggle",KEY_F11), "Fullscreen key cannot become a gameplay binding")
	for size: Vector2i in SIZES:
		var rect: Rect2 = AppSettings.presentation_rect(size)
		check(rect.size.x <= size.x and rect.size.y <= size.y and rect.position.x >= 0 and rect.position.y >= 0, "Presentation fits " + str(size))
		check(absf(rect.size.x / rect.size.y - 16.0/9.0) < 0.003, "Proportions preserved to output-pixel rounding " + str(size))
		check(rect.size.x >= size.x - 1 or rect.size.y >= size.y - 1, "Available aspect-correct area is filled " + str(size))
		check(AppSettings.integer_presentation(size) == (size == Vector2i(960,540) or size == Vector2i(1920,1080)), "Integer choice or nearest fallback " + str(size))
	var safe: Rect2i = AppSettings.fit_window_rect(Rect2i(9000,-8000,8000,5000), Rect2i(1920,0,1366,768), Vector2i(16,39))
	check(Rect2i(1920,0,1366,768).encloses(safe) and safe.size.x <= 1350 and safe.size.y <= 729, "Stale monitor/oversize preferences fit usable desktop")
	var invalid := ConfigFile.new()
	invalid.set_value("display","window_scale","bad")
	invalid.set_value("display","windowed_rect","bad")
	invalid.set_value("interface","ui_scale","bad")
	check(invalid.save(settings.path) == OK and settings.load_settings(), "Malformed display values load safely")
	check(settings.window_scale == 1 and settings.windowed_rect == Rect2i() and settings.ui_scale == 1, "Malformed display values recover defaults")
	var app: AppRoot = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(app)
	await settle()
	await photo("menu_windowed")
	if DisplayServer.get_name() != "headless":
		print("DISPLAY HARDWARE screens=", DisplayServer.get_screen_count(), " current=", root.current_screen, " size=", DisplayServer.screen_get_size(root.current_screen))
		for size: Vector2i in SIZES.slice(0,4):
			root.size = size
			root.position = AppSettings.fit_window_rect(Rect2i(Vector2i.ZERO,size),DisplayServer.screen_get_usable_rect(root.current_screen),root.get_size_with_decorations()-root.size,root.position-root.get_position_with_decorations()).position
			await settle(10)
			check(root.size == size, "Actual decorated client size " + str(size))
			check(root.get_visible_rect().size == Vector2(960,540), "Logical size unchanged at " + str(size))
			var transform: Transform2D = root.get_final_transform()
			var wanted: Rect2 = AppSettings.presentation_rect(size)
			check(transform.origin.is_equal_approx(wanted.position) and (transform * Vector2(960,540) - transform.origin).is_equal_approx(wanted.size), "Engine transform matches presentation at " + str(size))
			await click(app.menu.buttons[&"settings"])
			check(app.menu.window.visible, "Physical mouse hit matches settings at " + str(size))
			app.menu.close_window()
			if capture: await simulate(size)
		var remembered: Rect2i = Rect2i(root.position,root.size)
		await key(KEY_F11)
		check(root.mode == Window.MODE_FULLSCREEN and settings.fullscreen, "F11 enters supported borderless fullscreen")
		check(root.size == DisplayServer.screen_get_size(root.current_screen), "Fullscreen covers actual monitor")
		await photo("menu_fullscreen_native",true)
		check(settings.save_settings(), "Fullscreen choice saves")
		var fullscreen_reload := AppSettings.new(settings.path)
		check(fullscreen_reload.load_settings() and fullscreen_reload.fullscreen, "Fresh launch preferences retain fullscreen")
		await key(KEY_ENTER,true)
		print("RESTORE expected=", remembered, " actual=", Rect2i(root.position,root.size), " mode=", root.mode, " stored=", settings.windowed_rect)
		check(root.mode == Window.MODE_WINDOWED and Rect2i(root.position,root.size) == remembered, "Alt+Enter restores resized window and position")
		check(app.session == null, "Fullscreen shortcut cannot activate New Game")
		check(settings.save_settings(), "Display preferences persist")
		var loaded := AppSettings.new(settings.path)
		check(loaded.load_settings() and loaded.windowed_rect == remembered and not loaded.fullscreen and loaded.vsync, "Fresh settings restore rectangle/mode/VSync")
		settings.set_display(false,1,false)
		settings.apply_display(root)
		await settle(10)
	await click(app.menu.buttons[&"new_game"])
	check(app.session != null and app.menu == null, "Scaled mouse starts actual New Game")
	if app.session != null:
		var main: Node = app.session
		var ui: GameUI = main.game_ui
		check(main.lunar_base != null, "Production base remains enabled")
		await photo("game_windowed")
		var player_zoom: int = main.camera_rig.zoom_level
		var manager_zoom: int = main.management_camera.zoom_level
		var player_position: Vector2 = main.astronaut.global_position
		if DisplayServer.get_name() != "headless":
			await key(KEY_F11)
			await photo("game_fullscreen_native",true)
			check(main.astronaut.global_position == player_position and main.camera_rig.zoom_level == player_zoom and main.management_camera.zoom_level == manager_zoom, "Display toggle preserves actor and both camera zooms")
		await key(KEY_I)
		check(ui.inventory_window.visible and not main.astronaut.control_enabled, "Inventory remains modal after display changes")
		await photo("inventory_fullscreen")
		await key(KEY_ESCAPE)
		await key(KEY_TAB)
		check(ui.dashboard.visible, "Base Management works after display changes")
		await click(ui.dashboard.rail_buttons[&"power"])
		check(ui.dashboard.current == &"power" and main.astronaut.global_position == player_position, "Scaled dashboard mouse selects without movement")
		await photo("dashboard_fullscreen")
		await key(KEY_ESCAPE)
		check(ui.system_menu.visible, "Mission menu opens in fullscreen")
		ui.system_menu.show_page(&"database")
		await photo("database_fullscreen")
		ui.system_menu.show_page(&"settings")
		await photo("settings_fullscreen")
		check(root.get_visible_rect().encloses(ui.system_menu.window.get_global_rect()), "Settings/database modal stays in logical view")
		if capture:
			for factor: float in AppSettings.UI_SCALES:
				settings.set_interface(factor,false,true)
				await settle()
				for control: Control in [ui.system_menu.window,ui.system_menu.settings_panel.window_mode,ui.system_menu.settings_panel.vsync,ui.system_menu.settings_panel.reset_everything]:
					var bounds: Rect2 = control.get_global_transform_with_canvas() * Rect2(Vector2.ZERO,control.size)
					check(root.get_visible_rect().encloses(bounds), "Visible settings control at interface scale " + str(factor) + ": " + control.name)
				var sync_before: bool = settings.vsync
				await click(ui.system_menu.settings_panel.vsync)
				check(settings.vsync != sync_before, "Canvas-scaled mouse hit at interface scale " + str(factor))
				await click(ui.system_menu.settings_panel.vsync)
				await photo("interface_%d_percent" % roundi(factor*100))
			settings.set_interface(1,false,true)
			await settle()
		await key(KEY_ESCAPE)
		if DisplayServer.get_name() != "headless" and capture:
			for size: Vector2i in SIZES.slice(4): await simulate(size)
		if DisplayServer.get_name() != "headless":
			await key(KEY_F11)
			print("GAME RESTORE mode=",root.mode," size=",root.size," stored=",settings.windowed_rect)
			check(root.mode == Window.MODE_WINDOWED and root.size == Vector2i(960,540), "Gameplay toggle restores 960x540 decorated window")
	app.queue_free()
	await settle()
	settings.detach_window()
	root.always_on_top = original_topmost
	AppSettings.replace_shared(original)
	if failures.is_empty(): print("PASS: %d display/presentation/application checks" % checks)
	else:
		for failure: String in failures: printerr("FAIL: " + failure)
	quit(0 if failures.is_empty() else 1)
