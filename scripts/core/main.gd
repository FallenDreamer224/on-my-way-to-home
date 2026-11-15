extends Node
## Composition root. Future systems are composed here instead of global singletons.

@export var development_settings: DevelopmentSettings

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
		safety.notice_requested.connect(func(text: String, duration: float) -> void: game_ui.notify(text, duration))
		if not safety.configure(astronaut, ground, gameplay_modes, tutorial.eva_limits):
			push_error("Could not configure lunar EVA safety policy.")
	$Systems/HabitatDirector.configure(self)
	var utilities: UtilityService = $Systems/Utilities
	var utility_panel := UtilityPanel.new()
	utility_panel.name = "UtilityPanel"
	game_ui.add_child(utility_panel)
	utility_panel.configure(utilities, player_session)
	$Systems/HabitatDirector.utilities = utilities
	$Systems/HabitatDirector.utility_panel = utility_panel
	var daily := DailyLife.new()
	daily.name = "DailyLife"
	utilities.add_child(daily)
	daily.configure(utilities, inventory)
	var daily_panel := DailyLifePanel.new()
	game_ui.add_child(daily_panel)
	daily_panel.configure(daily, player_session)
	$Systems/HabitatDirector.daily_panel = daily_panel
	utilities.critical_notice.connect(func(text: String) -> void: game_ui.notify(text, 6))
	if development_active and development_settings.log_startup:
		print("On My Way to Home | Phase 0.7C UI ready")


func _apply_mode(_mode: GameplayModeCoordinator.Mode) -> void:
	if is_instance_valid(astronaut) and astronaut.control_enabled != gameplay_modes.is_player_mode():
		astronaut.set_control_enabled(gameplay_modes.is_player_mode())
	if is_instance_valid(chiwis) and chiwis.follow_enabled != gameplay_modes.is_player_mode():
		chiwis.set_follow_enabled(gameplay_modes.is_player_mode())
