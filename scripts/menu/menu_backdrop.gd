class_name MenuBackdrop
extends Node2D
## Title-scene diorama. Every element is existing project artwork at native 1:1 scale
## (terrain tiles, base and lander packs, props, astronaut, Chiwis) plus two sky layers made for
## the menu. Positions use each asset's measured ground anchor. Presentation only: there is no
## collision, walkability, interaction or mission meaning here.

const TERRAIN: PackedScene = preload("res://scenes/world/terrain_layer.tscn")
const PROP: PackedScene = preload("res://scenes/world/world_prop.tscn")
const HORIZON_FADE: Shader = preload("res://resources/menu/horizon_fade.gdshader")
const ASTRONAUT_ART: CharacterArtProfile = preload("res://resources/characters/astronaut_art.tres")
const CHIWIS_ART: CharacterArtProfile = preload("res://resources/characters/chiwis_art.tres")
const EARTH: String = "res://assets/ui/ui_pack_f/menu_earth.png"
const RIDGE: String = "res://assets/ui/ui_pack_f/menu_lunar_ridge.png"
const BASE: String = "res://assets/buildings/base_pack_c/"
const LANDER: String = "res://assets/vehicles/lander_pack_d/"
const PROPS: String = "res://assets/environment/props_pack_b/"
const SPACE_COLOR: Color = Color("05080c")
## World position of ground cell (0, 0). One cell step is 32 px across and 16 px down.
const ORIGIN: Vector2 = Vector2(480, 300)
const RIDGE_BASE_Y: float = 232.0
## Measured opaque bounds of the hill group inside its padded 792 x 96 canvas.
const RIDGE_OPAQUE: Rect2 = Rect2(235, 43, 321, 23)
const FAR_GROUND_COLOR: Color = Color("898989")
const DRIFT_PIXELS: float = 7.0
const DRIFT_PERIOD: float = 28.0
## [texture path, measured ground anchor in image pixels, screen column (i - j), screen row (i + j)]
const PLACEMENTS: Array[Array] = [
	[BASE + "solar_panel_array.png", Vector2i(67, 118), -3.0, 1.0],
	[BASE + "communications_antenna.png", Vector2i(43, 122), 4.0, 0.0],
	[BASE + "small_habitat_module.png", Vector2i(93, 169), 1.0, 3.0],
	[BASE + "utility_oxygen_tank.png", Vector2i(45, 106), -0.5, 5.5],
	[BASE + "battery_power_unit.png", Vector2i(42, 75), 3.5, 5.5],
	[PROPS + "small_resource_canister.png", Vector2i(31, 54), 2.0, 6.5],
	[LANDER + "moon_lander.png", Vector2i(160, 284), 9.0, 9.0],
	[BASE + "light_beacon_pole.png", Vector2i(41, 99), 3.0, 9.0],
	[LANDER + "support_cargo_container.png", Vector2i(33, 53), 12.0, 11.0],
	[BASE + "storage_crate_large.png", Vector2i(46, 92), -1.0, 11.0],
	[PROPS + "tool_case.png", Vector2i(32, 53), 0.5, 12.0],
	[PROPS + "utility_crate.png", Vector2i(31, 56), -2.5, 12.5],
	[PROPS + "rock_cluster.png", Vector2i(32, 51), -9.0, 12.5],
	[PROPS + "rock_cluster.png", Vector2i(32, 51), 14.0, 13.0],
	[PROPS + "beacon_marker.png", Vector2i(32, 57), 6.5, 13.5],
]
const LANDER_SPOT: Vector2 = Vector2(9.0, 9.0)
const BEACON_SPOT: Vector2 = Vector2(3.0, 9.0)
const ASTRONAUT_SPOT: Vector2 = Vector2(5.0, 11.5)
const CHIWIS_SPOT: Vector2 = Vector2(3.6, 12.3)

var sky: Node2D
var ridge: Node2D
var diorama: Node2D
var entities: Node2D
var astronaut_visual: AstronautAnimation
var chiwis_visual: AstronautAnimation
var beacon_light: ColorRect
var _time: float = 0.0
var _chiwis_body: Node2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var space := ColorRect.new()
	space.name = "Space"
	space.color = SPACE_COLOR
	space.position = Vector2(-80, -60)
	space.size = Vector2(1120, 680)
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(space)
	sky = Node2D.new()
	sky.name = "Sky"
	add_child(sky)
	sky.add_child(MenuStarfield.new())
	if ResourceLoader.exists(EARTH):
		var earth := Sprite2D.new()
		earth.name = "Earth"
		earth.texture = load(EARTH)
		earth.position = Vector2(654, 92)
		sky.add_child(earth)
	ridge = Node2D.new()
	ridge.name = "Ridge"
	add_child(ridge)
	_build_ridge()
	diorama = Node2D.new()
	diorama.name = "Diorama"
	add_child(diorama)
	_build_ground()
	_build_entities()
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position = Vector2(480, 270)
	add_child(camera)
	camera.make_current()
	set_process(not UiMotion.reduced)
	if not UiMotion.reduced:
		_animate()


func _process(delta: float) -> void:
	# Slow lateral drift. Whole-pixel offsets per layer give depth without sub-pixel shimmer.
	_time += delta
	var drift: float = sin(_time * TAU / DRIFT_PERIOD) * DRIFT_PIXELS
	diorama.position.x = -roundf(drift)
	ridge.position.x = -roundf(drift * 0.45)
	sky.position.x = -roundf(drift * 0.15)


static func ground_point(column: float, row: float) -> Vector2:
	return ORIGIN + Vector2(column * 32.0, row * 16.0)


func _build_ridge() -> void:
	# Plain far ground behind the dithered edge of the tile band.
	var plain := ColorRect.new()
	plain.name = "FarGround"
	plain.color = FAR_GROUND_COLOR
	plain.position = Vector2(-80, RIDGE_BASE_Y - 1.0)
	plain.size = Vector2(1120, 46)
	plain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ridge.add_child(plain)
	if not ResourceLoader.exists(RIDGE):
		return
	var texture: Texture2D = load(RIDGE)
	# Alternate the hill group with its mirror so neighbours always meet on identical columns.
	# The joins fall behind the lander, behind the habitat and under the menu column.
	var join: float = ground_point(LANDER_SPOT.x, LANDER_SPOT.y).x
	for index: int in range(-3, 2):
		var mirrored: bool = posmod(index, 2) == 0
		var piece := Sprite2D.new()
		piece.name = "Ridge%d" % (index + 3)
		piece.texture = texture
		piece.centered = false
		piece.flip_h = mirrored
		var inset: float = texture.get_width() - RIDGE_OPAQUE.end.x if mirrored else RIDGE_OPAQUE.position.x
		piece.position = Vector2(join + index * RIDGE_OPAQUE.size.x - inset, RIDGE_BASE_Y - RIDGE_OPAQUE.end.y)
		ridge.add_child(piece)


func _build_ground() -> void:
	var ground: TerrainLayer = TERRAIN.instantiate()
	ground.name = "Ground"
	ground.region = MenuTerrainRegion.new()
	# The scene's own (-32, -16) alignment keeps cell (0, 0) centered on ORIGIN.
	ground.position += ORIGIN
	var fade := ShaderMaterial.new()
	fade.shader = HORIZON_FADE
	fade.set_shader_parameter(&"fade_top", RIDGE_BASE_Y - 4.0)
	fade.set_shader_parameter(&"fade_bottom", RIDGE_BASE_Y + 34.0)
	ground.material = fade
	diorama.add_child(ground)
	var decal := Sprite2D.new()
	decal.name = "LandingDecal"
	decal.texture = load(LANDER + "landing_marker_decal.png")
	decal.centered = false
	decal.position = ground_point(LANDER_SPOT.x, LANDER_SPOT.y) - Vector2(144, 144)
	diorama.add_child(decal)


func _build_entities() -> void:
	entities = Node2D.new()
	entities.name = "Entities"
	entities.y_sort_enabled = true
	diorama.add_child(entities)
	for entry: Array in PLACEMENTS:
		_place(entry[0], entry[1], ground_point(entry[2], entry[3]))
	# The ramp hangs from the lander hatch threshold recorded in the Pack D manifest.
	var lander_corner: Vector2 = ground_point(LANDER_SPOT.x, LANDER_SPOT.y) - Vector2(160, 284)
	_place(LANDER + "deployed_ramp.png", Vector2i(86, 106), lander_corner + Vector2(205, 207) - Vector2(34, 24) + Vector2(86, 106))
	var beacon: Vector2 = ground_point(BEACON_SPOT.x, BEACON_SPOT.y)
	beacon_light = ColorRect.new()
	beacon_light.name = "BeaconLight"
	beacon_light.color = Color("e3b65c")
	beacon_light.size = Vector2(3, 3)
	beacon_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lamp := Node2D.new()
	lamp.name = "BeaconLamp"
	# Sorted just in front of the pole it sits on.
	lamp.position = beacon + Vector2(0, 1)
	beacon_light.position = Vector2(-12, -76)
	lamp.add_child(beacon_light)
	entities.add_child(lamp)
	astronaut_visual = _actor("Astronaut", ASTRONAUT_ART, ground_point(ASTRONAUT_SPOT.x, ASTRONAUT_SPOT.y), &"n")
	chiwis_visual = _actor("Chiwis", CHIWIS_ART, ground_point(CHIWIS_SPOT.x, CHIWIS_SPOT.y), &"n")
	_chiwis_body = chiwis_visual.get_parent()


func _place(path: String, anchor: Vector2i, at: Vector2) -> void:
	var appearance := PropAppearance.new()
	appearance.texture = load(path)
	appearance.ground_anchor = anchor
	var prop: WorldProp = PROP.instantiate()
	prop.name = path.get_file().get_basename().to_pascal_case()
	prop.appearance = appearance
	prop.position = at
	entities.add_child(prop, true)


func _actor(actor_name: String, art: CharacterArtProfile, at: Vector2, facing: StringName) -> AstronautAnimation:
	var body := Node2D.new()
	body.name = actor_name
	body.position = at
	var visual := AstronautAnimation.new()
	visual.name = "AnimatedSprite2D"
	visual.art_profile = art
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(visual)
	entities.add_child(body)
	visual.select_state(&"idle", facing)
	return visual


func _animate() -> void:
	UiMotion.blink(beacon_light, 2.2)
	# The astronaut looks between the sky and the base; Chiwis trots a short patrol.
	var gaze: Tween = astronaut_visual.create_tween().set_loops()
	for facing: StringName in [&"n", &"nw", &"n", &"ne"]:
		gaze.tween_interval(5.5)
		gaze.tween_callback(astronaut_visual.select_state.bind(&"idle", facing))
	var home: Vector2 = _chiwis_body.position
	var away: Vector2 = home + Vector2(-58, 0)
	var seconds: float = home.distance_to(away) / 90.0
	var patrol: Tween = _chiwis_body.create_tween().set_loops()
	patrol.tween_interval(6.0)
	patrol.tween_callback(chiwis_visual.select_state.bind(&"walk", &"w"))
	patrol.tween_property(_chiwis_body, "position", away, seconds)
	patrol.tween_callback(chiwis_visual.select_state.bind(&"idle", &"s"))
	patrol.tween_interval(4.0)
	patrol.tween_callback(chiwis_visual.select_state.bind(&"walk", &"e"))
	patrol.tween_property(_chiwis_body, "position", home, seconds)
	patrol.tween_callback(chiwis_visual.select_state.bind(&"idle", &"n"))
	patrol.tween_interval(3.0)
