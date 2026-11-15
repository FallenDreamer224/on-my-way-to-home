extends Node
## Gameplay session composition root. Systems are composed here instead of global singletons.
## The application root creates this scene through GameEntry.new_game(); it also runs alone.

const TUTORIAL_MISSION: MissionDefinition = preload("res://resources/data/moon_tutorial_mission.tres")

@export var development_settings: DevelopmentSettings
## Mission card shown by the objective interface; the Moon tutorial when left unset.
@export var mission: MissionDefinition

var objectives: ObjectiveTracker
var companion_dialogue: ChiwisDialogue
@onready var game_ui: GameUI = $UI
@onready var camera_rig: PlayerCameraRig = $CameraRig
@onready var astronaut: Astronaut = $World/Entities/Players/Astronaut
@onready var chiwis: Chiwis = $World/Entities/NPCs/Chiwis
@onready var management_camera: BaseManagementCameraRig = $BaseManagementCameraRig
@onready var gameplay_modes: GameplayModeCoordinator = $Systems/GameplayModes
@onready var player_session: PlayerSession = $Systems/PlayerSession


func _ready() -> void:
	var ground: TerrainLayer = $World/Terrain/Ground
	var bounds: Rect2 = ground.world_rect()
	camera_rig.world_bounds = bounds
	camera_rig.bounds_enabled = true
	management_camera.world_bounds = bounds
	management_camera.bounds_enabled = true
	astronaut.global_position = IsometricGrid.tile_to_world(Vector2i.ZERO, ground)
	astronaut.configure_terrain(ground)
	chiwis.global_position = IsometricGrid.tile_to_world(Vector2i(0, 1), ground)
	chiwis.configure_terrain(ground)
	chiwis.set_follow_target(astronaut)
	camera_rig.set_follow_target(astronaut)
	gameplay_modes.mode_changed.connect(_apply_mode)
	gameplay_modes.initialize(camera_rig, management_camera)
	var inventory: RuntimeInventory = astronaut.get_node("Inventory")
	var detector: InteractionDetector = astronaut.get_node("InteractionDetector")
	detector.configure(astronaut, inventory)
	var development_active: bool = (
		development_settings != null and development_settings.is_active()
	)
	game_ui.configure(inventory, detector, gameplay_modes, management_camera,
		development_active and development_settings.show_development_screen)
	player_session.configure(astronaut, gameplay_modes, detector, game_ui.inventory_window)
	var safety: EvaSafetyMonitor = $Systems/EvaSafety
	var tutorial: LunarTutorialRegion = ground.region as LunarTutorialRegion
	if tutorial != null:
		if not safety.configure(astronaut, ground, gameplay_modes, tutorial.eva_limits):
			push_error("Could not configure lunar EVA safety policy.")
	var director: HabitatDirector = $Systems/HabitatDirector
	director.configure(self)
	var utilities: UtilityService = $Systems/Utilities
	var utility_panel := UtilityPanel.new()
	utility_panel.configure(utilities, player_session, development_active)
	game_ui.register_modal(utility_panel)
	director.utilities = utilities
	director.utility_panel = utility_panel
	var daily := DailyLife.new()
	daily.name = "DailyLife"
	utilities.add_child(daily)
	daily.configure(utilities, inventory)
	var daily_panel := DailyLifePanel.new()
	daily_panel.configure(daily, player_session)
	game_ui.register_modal(daily_panel)
	director.daily_panel = daily_panel
	utilities.critical_notice.connect(func(text: String) -> void: game_ui.notify(text, 6, NotificationArea.Level.CRITICAL))
	_compose_presentation(inventory, detector, director, utilities, safety, daily, utility_panel)
	if development_active and development_settings.log_startup:
		print("On My Way to Home | Phase 0.8F interface ready")


## Objective tracking and companion commentary observe existing systems; neither owns gameplay.
func _compose_presentation(inventory: RuntimeInventory, detector: InteractionDetector, director: HabitatDirector,
		utilities: UtilityService, safety: EvaSafetyMonitor, daily: DailyLife, utility_panel: UtilityPanel) -> void:
	objectives = ObjectiveTracker.new()
	objectives.name = "Objectives"
	$Systems.add_child(objectives)
	companion_dialogue = ChiwisDialogue.new()
	companion_dialogue.name = "ChiwisDialogue"
	$Systems.add_child(companion_dialogue)
	var commentary := ChiwisCommentary.new()
	commentary.name = "ChiwisCommentary"
	$Systems.add_child(commentary)
	if not objectives.configure(mission if mission != null else TUTORIAL_MISSION, inventory, director, daily):
		push_error("Invalid tutorial mission definition.")
	commentary.configure(companion_dialogue, inventory, detector, director, safety, utilities, objectives, gameplay_modes)
	game_ui.bind_systems(player_session, director, utilities, safety, daily, objectives, companion_dialogue, inventory)
	game_ui.inventory_window.visibility_changed.connect(func() -> void:
		if game_ui.inventory_window.visible:
			objectives.note_event(&"inventory_opened"))
	gameplay_modes.mode_changed.connect(func(mode: GameplayModeCoordinator.Mode) -> void:
		if mode == GameplayModeCoordinator.Mode.BASE_MANAGEMENT:
			objectives.note_event(&"management_visited"))
	utility_panel.visibility_changed.connect(func() -> void:
		if utility_panel.visible:
			objectives.note_event(&"utility_terminal_opened")
			commentary.note_utility_terminal())


func _apply_mode(_mode: GameplayModeCoordinator.Mode) -> void:
	if is_instance_valid(astronaut) and astronaut.control_enabled != gameplay_modes.is_player_mode():
		astronaut.set_control_enabled(gameplay_modes.is_player_mode())
	if is_instance_valid(chiwis) and chiwis.follow_enabled != gameplay_modes.is_player_mode():
		chiwis.set_follow_enabled(gameplay_modes.is_player_mode())
