extends SceneTree
## Startup contract for the classes that previously failed in an already-open editor.
var failures: PackedStringArray = []
var checks: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label)

func run() -> void:
	var classes: Dictionary[String, String] = {
		"res://scripts/gameplay/eva_safety_monitor.gd": "EvaSafetyMonitor",
		"res://scripts/gameplay/eva_safety_limits.gd": "EvaSafetyLimits",
		"res://scripts/world/lunar_tutorial_region.gd": "LunarTutorialRegion",
		"res://scripts/utilities/utility_service.gd": "UtilityService",
		"res://scripts/ui/utility_panel.gd": "UtilityPanel",
		"res://scripts/habitat/daily_life.gd": "DailyLife",
		"res://scripts/ui/daily_life_panel.gd": "DailyLifePanel"}
	for path: String in classes:
		var script := load(path) as Script
		check(script != null and script.can_instantiate(), "Script parses: " + path)
		if script != null:
			check(script.get_global_name() == StringName(classes[path]), "Exact registered name: " + classes[path])
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	var safety: EvaSafetyMonitor = main.get_node("Systems/EvaSafety")
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var region: LunarTutorialRegion = ground.region as LunarTutorialRegion
	check(region != null and region.eva_limits is EvaSafetyLimits, "eva_limits is the authored instance Resource")
	if region != null:
		check(safety.limits == region.eva_limits, "Main passes the actual terrain policy to the monitor")
		check(region.eva_limits == load("res://resources/config/lunar_eva_safety.tres"), "Existing safety configuration retained")
	var utilities: UtilityService = main.get_node("Systems/Utilities")
	var director: HabitatDirector = main.get_node("Systems/HabitatDirector")
	check(utilities.model.config != null and utilities.model.alarms.is_empty(), "Utility service initialized safely")
	check(director.utilities == utilities, "Habitat binds existing utility service")
	check(director.utility_panel is UtilityPanel and not director.utility_panel.visible, "Utility panel constructed and configured")
	var daily: DailyLife = utilities.get_node("DailyLife")
	check(daily.utilities == utilities and daily.trays.size() == 2, "DailyLife initialized against utilities")
	check(director.daily_panel is DailyLifePanel and director.daily_panel.model == daily, "DailyLifePanel constructed and configured")
	check(main.astronaut is Astronaut and main.chiwis is Chiwis, "Original actors initialized")
	main.queue_free()
	await process_frame
	for failure: String in failures: printerr("FAIL: " + failure)
	if failures.is_empty(): print("PASS: %d class-resolution/startup checks" % checks)
	quit(0 if failures.is_empty() else 1)

