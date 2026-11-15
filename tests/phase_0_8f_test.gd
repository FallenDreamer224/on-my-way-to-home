extends SceneTree
## Focused recovery coverage for the inherited interface and application contracts.
const SETTINGS_PATH: String = "res://tests/output/phase_0_8f_recovery/test_settings.cfg"
var checks: int = 0
var failures: PackedStringArray = []

func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label)
func settle() -> void:
	await physics_frame
	await process_frame
func key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await settle()

func run() -> void:
	var original := AppSettings.shared()
	var settings := AppSettings.new(SETTINGS_PATH)
	settings.set_interface(1.25, true, true)
	settings.set_display(true, 2, false)
	check(settings.rebind(&"inventory_toggle", KEY_J), "Supported action rebinds")
	check(not settings.rebind(&"inventory_toggle", KEY_ESCAPE), "Escape remains reserved")
	check(not settings.rebind(&"unknown", KEY_J), "Unknown binding rejected")
	check(settings.save_settings(), "Preferences saved to isolated path")
	var loaded := AppSettings.new(SETTINGS_PATH)
	check(loaded.load_settings(), "Preferences load into a fresh object")
	check(loaded.fullscreen and loaded.window_scale == 2 and not loaded.vsync, "Display preferences survive restart")
	check(loaded.ui_scale == 1.25 and loaded.high_contrast and loaded.reduced_motion, "Accessibility preferences survive restart")
	check(loaded.bindings[&"inventory_toggle"] == KEY_J, "Remapped key persists")
	var corrupt := ConfigFile.new()
	corrupt.set_value("input", "player_move_up", KEY_S)
	corrupt.set_value("input", "player_move_down", KEY_S)
	corrupt.set_value("input", "inventory_toggle", KEY_ESCAPE)
	corrupt.set_value("interface", "ui_scale", 999.0)
	check(corrupt.save(SETTINGS_PATH) == OK and loaded.load_settings(), "Conflicting settings file handled")
	var seen: Array[int] = []
	for action: StringName in AppSettings.REMAPPABLE:
		check(loaded.bindings[action] not in seen, "Loaded bindings stay unique: " + action)
		seen.append(loaded.bindings[action])
	check(loaded.ui_scale == 1.0 and loaded.bindings[&"inventory_toggle"] != KEY_ESCAPE, "Invalid scale and reserved key use safe defaults")
	settings.reset_all()
	settings.set_interface(1.0, false, true)
	AppSettings.replace_shared(settings)
	# Reduced motion settles every presentation helper synchronously and kills old motion.
	var panel := Panel.new()
	root.add_child(panel)
	UiMotion.fade_in(panel)
	check(panel.visible and panel.modulate.a == 1, "Reduced-motion fade-in settles")
	UiMotion.fade_out(panel)
	check(not panel.visible, "Reduced-motion fade-out hides")
	UiMotion.blink(panel)
	check(panel.modulate.a == 1 and not panel.has_meta(&"ui_motion_tween"), "Reduced motion creates no blink tween")
	panel.queue_free()
	# Queue/cooldown coverage includes the interruption path at maximum capacity.
	var dialogue := ChiwisDialogue.new()
	root.add_child(dialogue)
	dialogue.set_process(false)
	check(dialogue.say(&"tutorial", "Guidance", ChiwisDialogue.Priority.TUTORIAL, 3, 10), "Dialogue starts")
	check(not dialogue.say(&"tutorial", "Duplicate"), "Current topic deduplicated")
	for i: int in ChiwisDialogue.MAX_QUEUE:
		check(dialogue.say(StringName("q%d" % i), "Queued guidance", ChiwisDialogue.Priority.TUTORIAL), "Queue accepts guidance")
	check(dialogue.say(&"urgent", "Boundary", ChiwisDialogue.Priority.CRITICAL), "Critical dialogue interrupts")
	check(dialogue.current.topic == &"urgent" and dialogue.pending_count() == ChiwisDialogue.MAX_QUEUE, "Urgent interruption preserves queue bound")
	dialogue.hold = true
	dialogue.advance(100)
	check(dialogue.current.topic == &"urgent", "Modal holds the visible dialogue")
	dialogue.hold = false
	check(dialogue.dismiss() and dialogue.current.topic == &"tutorial", "Interrupted guidance resumes first")
	dialogue.clear()
	check(not dialogue.is_speaking() and dialogue.pending_count() == 0, "Clear removes current and pending lines")
	check(dialogue.say(&"cooldown", "Once", ChiwisDialogue.Priority.REMARK, 3, 10), "Cooldown line accepted")
	dialogue.dismiss()
	check(not dialogue.say(&"cooldown", "Too early"), "Cooldown blocks repeat after dismissal")
	dialogue.advance(10)
	check(dialogue.say(&"cooldown", "Ready"), "Cooldown expires")
	dialogue.clear()
	check(not dialogue.say(&"nan", "Bad", ChiwisDialogue.Priority.REMARK, NAN), "Nonfinite dialogue duration rejected")
	for i: int in 45:
		dialogue.say(StringName("history%d" % i), "History entry")
		dialogue.dismiss()
	check(dialogue.history.size() == ChiwisDialogue.MAX_HISTORY, "Companion history bounded")
	dialogue.queue_free()
	# Runtime research fields are exact copies; game_usage stays a separate authored field.
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/research/nasa_technology_catalog.json"))
	var database := EquipmentDatabase.load_default()
	check(database != null and database.records.size() == 26, "Curated 26-record equipment database loads")
	check(database.catalog_version == registry.catalog_version and database.reviewed_through == registry.reviewed_through, "Database retains evidence version/date")
	for record: EquipmentRecord in database.records:
		var source: Dictionary = {}
		for entry: Dictionary in registry.entries:
			if entry.id == String(record.research_id): source = entry
		check(not source.is_empty() and record.is_valid_record(), "Valid canonical research ID: " + record.research_id)
		check(record.evidence_status == StringName(source.evidence_status) and record.testing_environment == source.actual_testing_environment, "Evidence status/environment retained: " + record.research_id)
		check(record.actual_function == source.actual_function and record.reference_url == source.official_reference_url and record.limitations == PackedStringArray(source.limitations_and_uncertainties), "Facts/source/uncertainties retained: " + record.research_id)
	check(EquipmentDatabase.STATUS_NOTES[&"operational"].contains("does not imply lunar deployment"), "Operational disclaimer explicit")
	for name: StringName in UiIcons.PACK_F_NAMES:
		check(UiIcons.has_icon(name) and UiIcons.texture(name).get_size() == Vector2(32, 32), "Every Pack F name has native art or explicit fallback: " + name)
	# The actual configured entry must show the menu; all session ownership stays with AppRoot.
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/app_root.tscn", "Configured startup uses application root")
	var app: AppRoot = load("res://scenes/app_root.tscn").instantiate()
	root.add_child(app)
	await settle()
	check(app.menu != null and app.session == null and not app.busy, "Menu initializes without spawning gameplay")
	settings.set_interface(1.0, false, false)
	check(app.menu.backdrop.can_process(), "Normal title presentation remains animated")
	settings.set_interface(1.0, false, true)
	check(not app.menu.backdrop.can_process(), "Live reduced-motion toggle stops existing diorama and bound tweens")
	check(not app.has_compatible_save() and app.menu.buttons[&"continue"].disabled, "No save system: Continue safely disabled")
	# An invalid file cannot become a session; there is intentionally no invented save format.
	var invalid := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	invalid.store_string("invalid session")
	invalid.close()
	check(not app.has_compatible_save(), "Invalid save-like file cannot enable Continue")
	app.menu.open_settings()
	check(app.menu.window.visible and app.menu.settings_panel.visible, "Settings opens from title")
	app.menu.close_window()
	app.menu.open_credits()
	check(app.menu.window.visible and app.menu.credits_view.visible, "Credits opens from title")
	app.menu.close_window()
	# Drive New Game with native input on the actual focused title button.
	app.menu.buttons[&"new_game"].grab_focus()
	await key(KEY_ENTER)
	await settle()
	check(app.menu == null and is_instance_valid(app.session) and not app.busy, "Enter on New Game starts one hosted session")
	check(not await app.start_new_game(), "A second session cannot be spawned")
	var ui: GameUI = app.session.game_ui
	check(ui.hosted and ui.open_system_menu() and paused, "Hosted mission menu pauses gameplay")
	check(ui.system_menu.return_button.visible, "Return-to-menu control offered")
	ui.system_menu.show_page(&"database")
	check(ui.system_menu.current_page == &"database", "Scientific database page opens")
	ui.system_menu.show_page(&"settings")
	for scale: float in AppSettings.UI_SCALES:
		settings.set_interface(scale, true, true)
		await settle()
		check(root.get_visible_rect().encloses(ui.system_menu.window.get_global_rect()), "Settings modal fits UI scale %.2f" % scale)
	ui.close_system_menu()
	check(not paused, "Closing the mission menu resumes")
	check(await app.return_to_menu(), "Return transaction succeeds")
	check(app.menu != null and app.session == null and not paused, "Return destroys the session and restores title")
	check(await app.start_new_game(), "Fresh session can start after returning")
	check(app.session.astronaut.get_node("Inventory").get_quantity(&"lunar_sample") == 0, "New Game starts fresh inventory")
	await app.return_to_menu()
	# Use the real display API only when a graphics driver exists; restore previous state.
	if DisplayServer.get_name() != "headless":
		var old_mode: Window.Mode = root.mode
		settings.set_display(true, 1, true)
		settings.apply_display(root)
		await settle()
		check(root.mode == Window.MODE_FULLSCREEN, "Fullscreen preference applies to real window")
		settings.set_display(false, 1, true)
		settings.apply_display(root)
		await settle()
		check(root.mode == Window.MODE_WINDOWED and root.size == Vector2i(960, 540), "Windowed size restored through settings")
		root.mode = old_mode
	app.queue_free()
	await process_frame
	AppSettings.replace_shared(original)
	for failure: String in failures: printerr("FAIL: " + failure)
	if failures.is_empty(): print("PASS: %d Phase 0.8F focused checks" % checks)
	quit(0 if failures.is_empty() else 1)
