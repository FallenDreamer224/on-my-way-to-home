extends "res://tests/demo_d0_test.gd"
## Real configured New Game, real walking/run inputs and autonomous companion movement.
const OUTPUT: String = "res://tests/output/phase_0_9_1/"
var app: AppRoot

func settle(count: int = 4) -> void:
	for i: int in count:
		await physics_frame
		await process_frame
func press_direction(vector: Vector2) -> void:
	release_walk()
	if vector.x != 0: Input.action_press("player_move_right" if vector.x > 0 else "player_move_left")
	if vector.y != 0: Input.action_press("player_move_down" if vector.y > 0 else "player_move_up")
func photo(name: String) -> void:
	if not capture: return
	# Capture framing only: retain the same 2x camera and bounds, but give the trailing
	# companion's full sprite headroom. Restore ordinary player framing after the image.
	var offset: Vector2 = main.camera_rig.follow_offset
	main.camera_rig.follow_offset = Vector2(0,-32)
	main.camera_rig.refresh_follow()
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(OUTPUT + name + ".png") == OK, "Live controller capture " + name)
	main.camera_rig.follow_offset = offset
	main.camera_rig.refresh_follow()
	await process_frame
	await RenderingServer.frame_post_draw
func wait_companion() -> void:
	for i: int in 400:
		if dog.state == Chiwis.State.IDLE: break
		await physics_frame
	check(dog.state == Chiwis.State.IDLE and not dog.running and dog.visual.state == &"idle", "Autonomous companion stops in idle")
func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var original: AppSettings = AppSettings.shared()
	var settings := AppSettings.new(OUTPUT + "running_preferences.cfg")
	settings.set_interface(1,false,true)
	settings.set_display(false,1,false)
	AppSettings.replace_shared(settings)
	app = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(app)
	await settle()
	app.menu.buttons[&"new_game"].grab_focus()
	await key(KEY_ENTER)
	await settle()
	check(app.session != null and app.menu == null, "Normal menu starts production session")
	if app.session == null:
		quit(1)
		return
	main = app.session
	actor = main.astronaut
	dog = main.chiwis
	director = main.get_node("Systems/HabitatDirector")
	inventory = actor.get_node("Inventory")
	check(main.lunar_base != null and main.camera_rig.follow_target == actor, "Actual installed base and astronaut camera remain active")
	check(actor.walk_speed == 80 and actor.run_speed == 140 and dog.movement_speed == 90 and dog.walk_speed == 80, "Explicit walking/run configuration and original companion cap")
	var center := Vector2(-320,224)
	for vector: Vector2 in AstronautDirections.VECTORS:
		check(actor.walkability.constrain_motion(center,vector.normalized()*112,actor.footprint_half_extent).is_equal_approx(vector.normalized()*112), "Southern test route is genuinely walkable: " + str(vector))
	check(await walk_to(center), "Reach clear southern regolith by real walking")
	for index: int in AstronautDirections.NAMES.size():
		var facing: StringName = AstronautDirections.NAMES[index]
		var vector: Vector2 = AstronautDirections.VECTORS[index].normalized()
		check(AstronautDirections.from_vector(vector) == facing, "Existing screen-facing direction mapper " + facing)
		check(await walk_to(center-vector*110), "Walk to directional staging point " + facing)
		await wait_companion()
		press_direction(vector)
		await settle(6)
		check(actor.visual.state == &"walk" and not actor.running and actor.facing == facing, "Real walk state before run " + facing)
		# Use the actual configured Shift key rather than calling the animation selector.
		var shift := InputEventKey.new()
		shift.physical_keycode = KEY_SHIFT
		shift.pressed = true
		Input.parse_input_event(shift)
		Input.flush_buffered_events()
		var observed_walk: bool = false
		var observed_run: bool = false
		for tick: int in 90:
			await physics_frame
			if dog.visual.state == &"walk": observed_walk = true
			if dog.visual.state == &"run" and dog.facing == facing: observed_run = true
		check(actor.running and actor.visual.animation == StringName("run_"+facing), "Astronaut live running direction " + facing)
		check(actor.velocity.length() <= actor.run_speed + 0.01 and actor.velocity.length() >= actor.run_speed-0.01, "Cardinal/diagonal run normalized " + facing)
		check(actor.visual.frame > 0 and actor.visual.is_playing(), "Run clock advances without per-frame restart " + facing)
		check(observed_walk and observed_run, "Chiwis independently walks then catches up running " + facing)
		check(dog.running and dog.visual.animation == StringName("run_"+facing), "Chiwis real autonomous running direction " + facing)
		check(dog.velocity.length() <= 90.01 and dog.follow_target == actor, "Original companion speed cap/target retained " + facing)
		await photo("astronaut_run_" + String(facing))
		await photo("chiwis_run_" + String(facing))
		var canvas: Transform2D = actor.get_canvas_transform()
		for body: Node2D in [actor,dog]:
			var sprite: AstronautAnimation = body.get_node("AnimatedSprite2D")
			check(body.scale == Vector2.ONE and sprite.scale == Vector2.ONE and not sprite.flip_h and not sprite.flip_v, "Native unflipped sprites " + facing)
			check((canvas * (sprite.global_position + sprite.get_frame_anchor())).is_equal_approx((canvas * body.global_position).round()), "Measured foot anchor stays on snapped ground " + facing)
		shift.pressed = false
		Input.parse_input_event(shift)
		Input.flush_buffered_events()
		await settle(2)
		check(not actor.running and actor.visual.animation == StringName("walk_"+facing), "Release Shift returns to walking " + facing)
		release_walk()
		await settle(2)
		check(actor.visual.animation == StringName("idle_"+facing) and not actor.running, "Release movement returns to facing idle " + facing)
		await wait_companion()
		# Shift while stationary must not produce a running pose.
		Input.action_press(&"player_run")
		await settle(2)
		check(actor.visual.state == &"idle" and not actor.running and not dog.running, "Stationary Shift cannot make either actor run " + facing)
		Input.action_release(&"player_run")
		Input.action_press(&"player_run")
		press_direction(vector)
		await settle(4)
		check(actor.running, "Direct idle-to-run transition " + facing)
		release_walk()
		await settle(2)
		check(actor.visual.animation == StringName("idle_"+facing) and not actor.running, "Stop while Shift held returns run directly to idle " + facing)
		Input.action_release(&"player_run")
	check(await walk_to(center), "Return by real walking for running turns")
	Input.action_press(&"player_run")
	press_direction(Vector2.RIGHT)
	await settle(4)
	press_direction(Vector2(1,-1))
	await settle(4)
	check(actor.running and actor.visual.animation == &"run_ne", "Turning while running keeps the run state and shared direction mapper")
	release_walk()
	Input.action_release(&"player_run")
	await settle(2)
	check(await walk_to(Vector2(0,-580)), "Reach real perimeter approach")
	Input.action_press(&"player_run")
	press_direction(Vector2.UP)
	await settle(100)
	check(actor.walkability.is_position_walkable(actor.global_position,actor.footprint_half_extent), "Running respects authoritative full-foot terrain/EVA walkability")
	check(actor.visual.state == &"idle" and not actor.running, "Blocked running does not play a moving animation")
	release_walk()
	Input.action_release(&"player_run")
	await settle(2)
	# Modal and mode handoff still own input even while run is held.
	await key(KEY_I)
	var before: Vector2 = actor.global_position
	Input.action_press(&"player_run")
	press_direction(Vector2.RIGHT)
	await settle(8)
	check(actor.global_position == before and actor.visual.state == &"idle", "Inventory blocks run movement and visuals")
	release_walk()
	Input.action_release(&"player_run")
	await key(KEY_ESCAPE)
	await key(KEY_TAB)
	Input.action_press(&"player_run")
	press_direction(Vector2.RIGHT)
	await settle(8)
	check(actor.global_position == before and not actor.running and main.game_ui.dashboard.visible, "Management mode blocks astronaut run")
	release_walk()
	Input.action_release(&"player_run")
	await key(KEY_TAB)
	await settle()
	check(actor.control_enabled and dog.follow_enabled, "Player and companion resume through existing coordinator")
	app.queue_free()
	await settle()
	settings.detach_window()
	AppSettings.replace_shared(original)
	if failures.is_empty(): print("PASS: %d live eight-direction running checks" % checks)
	else:
		for failure: String in failures: printerr("FAIL: " + failure)
	quit(0 if failures.is_empty() else 1)
