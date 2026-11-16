class_name InteriorArtRoom
extends HabitatRoom
## Presentation-ready compartment using existing actions, state and navigation contracts.

@export var room_id: StringName
@export var prepared_data: Dictionary
var art_data: Dictionary
var props: Dictionary[StringName, Node2D] = {}
var door_views: Dictionary[StringName, InteriorModule] = {}
var crop_views: Array[InteriorCropView] = []
var _bodies: Dictionary[Vector2i, CollisionPolygon2D] = {}

func _enter_tree() -> void:
	if definition.is_empty():
		setup(prepared_data.layout, HabitatRoomState.new(), Callable())

func setup(data: Dictionary, saved: HabitatRoomState, handler: Callable) -> void:
	super.setup(data, saved, handler)
	art_data = prepared_data
	var prepared := InteriorRoomRegion.new()
	prepared.origin = Vector2i.ZERO
	prepared.size = cell(data.size)
	prepared.floor_kind = TerrainRegion.Kind.LIGHT_REGOLITH if art_data.floor_treatment == "sealed_service" else TerrainRegion.Kind.REGOLITH
	for item: Dictionary in art_data.props:
		var origin := cell(item.cell)
		var footprint := cell(item.footprint)
		for y: int in footprint.y:
			for x: int in footprint.x: prepared.blocked_cells.append(origin + Vector2i(x, y))
	for extra: Array in data.extra_blocked_cells:
		if cell(extra) not in prepared.blocked_cells: prepared.blocked_cells.append(cell(extra))
	for door: Dictionary in art_data.portals: prepared.thresholds.append(cell(door.threshold))
	region = prepared
	$Floor.region = prepared
	$Floor.terrain_art = preload("res://resources/interiors/interior_floor.tres")

func _ready() -> void:
	# Cells, physical ground collision and the existing BFS use the same footprint.
	for y: int in region.size.y:
		for x: int in region.size.x:
			var at := Vector2i(x, y)
			if not $Floor.is_cell_walkable(at):
				var collider := CollisionPolygon2D.new()
				collider.polygon = diamond(IsometricGrid.tile_to_position(at))
				$Walls.add_child(collider)
				_bodies[at] = collider
	_build_walls()
	for portal: Dictionary in art_data.portals:
		if portal.pressure_boundary: set_door_closed(StringName(portal.id), true)
	for item: Dictionary in art_data.props:
		var prop: Node2D = (load("res://scenes/interiors/props/" + String(item.asset) + ".tscn") as PackedScene).instantiate()
		var metadata: InteriorPropDefinition = prop.get_meta("definition")
		prop.position = IsometricGrid.tile_to_position(cell(item.cell)) - Vector2(metadata.grid_origin)
		$Actors.add_child(prop)
		props[StringName(item.id)] = prop
		if item.has("tray_index"):
			var view := InteriorCropView.new()
			view.name = "CropView"
			prop.add_child(view)
			view.tray_index = int(item.tray_index)
			crop_views.append(view)
			# Original geometric LED support; the rejected generated frame contains plants.
			var gantry := Line2D.new()
			gantry.points = PackedVector2Array([Vector2(-52, -24), Vector2(-52, -112), Vector2(20, -76), Vector2(20, 12)])
			gantry.width = 2
			gantry.default_color = Color("a8bac5")
			prop.add_child(gantry)
			gantry.z_index = 2
			var lamp := Sprite2D.new()
			lamp.texture=load("res://assets/environment/interiors_g2/overhead_lamp.png")
			lamp.position=Vector2(-16,-94)
			prop.add_child(lamp)
			lamp.z_index=3
	for facility: Dictionary in definition.facilities:
		_make_action(StringName(facility.id), String(facility.title), &"facility", cell(facility.point))
	for door: Dictionary in definition.doors:
		_make_action(StringName(door.id), String(door.title), StringName(door.destination), cell(door.point))
	# Art inspection uses small existing world labels, without a second UI theme.
	for action: HabitatAction in actions.values():
		for child: Node in action.get_children():
			if child is Label: child.hide()
	var navigation := Node2D.new()
	navigation.name = "NavigationMarkers"
	add_child(navigation)
	for key: String in ["spawn", "companion_spawn"]:
		var marker := Marker2D.new()
		marker.name = key
		marker.position = IsometricGrid.tile_to_position(cell(definition[key]))
		navigation.add_child(marker)
	for portal: Dictionary in art_data.portals:
		for key: String in ["approach", "threshold"]:
			var marker := Marker2D.new()
			marker.name = String(portal.id) + "_" + key
			marker.position = IsometricGrid.tile_to_position(cell(portal[key]))
			navigation.add_child(marker)
	queue_redraw()

func _build_walls() -> void:
	var construction: Node2D = $Construction
	for x: int in range(region.size.x - 1):
		_add_wall(construction, Vector2i(x, 0), Vector2i(1, 0), false, InteriorModule.Kind.WINDOW if x % 3 == 1 else InteriorModule.Kind.WALL)
		_add_wall(construction, Vector2i(x, region.size.y - 1), Vector2i(1, 0), true)
	for y: int in range(region.size.y - 1):
		_add_wall(construction, Vector2i(0, y), Vector2i(0, 1), false, InteriorModule.Kind.SERVICE if y % 3 == 0 else InteriorModule.Kind.WALL)
		_add_wall(construction, Vector2i(region.size.x - 1, y), Vector2i(0, 1), true)
	for door: Dictionary in art_data.portals:
		var view := InteriorModule.new()
		view.kind = InteriorModule.Kind.DOOR
		view.position = IsometricGrid.tile_to_position(cell(door.threshold))
		var threshold := cell(door.threshold)
		view.axis = Vector2i(1,0) if threshold.y in [0,region.size.y-1] else Vector2i(0,1)
		view.z_index = -1
		construction.add_child(view)
		door_views[StringName(door.id)] = view
	for extra: Array in definition.extra_blocked_cells:
		var partition := InteriorModule.new()
		partition.position = IsometricGrid.tile_to_position(cell(extra))
		partition.cutaway = true
		construction.add_child(partition)
	for x: int in range(1, region.size.x - 2):
		_add_wall(construction, Vector2i(x, 0), Vector2i(1, 0), false, InteriorModule.Kind.CABLE_STRAIGHT)

func _add_wall(parent: Node2D, at: Vector2i, axis: Vector2i, low: bool, kind: InteriorModule.Kind = InteriorModule.Kind.WALL) -> void:
	for portal: Dictionary in art_data.portals:
		if cell(portal.threshold) == at: return
	var wall := InteriorModule.new()
	wall.position = IsometricGrid.tile_to_position(at)
	wall.axis = axis
	wall.cutaway = low
	wall.reinforced = room_id == &"shelter"
	wall.kind = kind
	parent.add_child(wall)

func set_door_closed(id: StringName, closed: bool) -> void:
	if not door_views.has(id): return
	door_views[id].closed = closed
	for portal: Dictionary in art_data.portals:
		if StringName(portal.id) != id: continue
		var at := cell(portal.threshold)
		if closed and at not in region.blocked_cells: region.blocked_cells.append(at)
		elif not closed: region.blocked_cells.erase(at)
		if not _bodies.has(at):
			var collider := CollisionPolygon2D.new()
			collider.polygon = diamond(IsometricGrid.tile_to_position(at))
			$Walls.add_child(collider)
			_bodies[at] = collider
		_bodies[at].set_deferred("disabled", not closed)
		$Floor.rebuild()

func bind_services(daily: DailyLife, director: HabitatDirector) -> void:
	for view: InteriorCropView in crop_views: view.bind_model(daily, view.tray_index)
	for id: StringName in [&"eclss", &"water", &"power", &"operations"]:
		if not props.has(id): continue
		var indicator := ExteriorStateIndicator.new()
		indicator.position = Vector2(0, -12)
		props[id].add_child(indicator)
		indicator.show()
		var equipment_id: String = {&"eclss":"ventilation", &"water":"water_treatment", &"power":"distribution", &"operations":"housekeeping"}[id]
		var refresh_equipment := func() -> void: indicator.display_equipment(daily.utilities.model.equipment[equipment_id])
		daily.utilities.model.changed.connect(refresh_equipment)
		refresh_equipment.call()
	if room_id == &"crew_airlock":
		var refresh := func() -> void:
			set_door_closed(&"outer", not director.airlock.outer_open)
			set_door_closed(&"inner", not director.airlock.inner_open)
		director.airlock_changed.connect(refresh)
		refresh.call()
	elif room_id == &"equipment_lock":
		var refresh_inner := func() -> void: set_door_closed(&"crew", not director.airlock.inner_open)
		director.airlock_changed.connect(refresh_inner)
		refresh_inner.call()

func _draw() -> void:
	# Keep interaction targets on the established unobstructed floor, not on art pixels.
	for action: HabitatAction in actions.values(): draw_rect(Rect2(action.position - Vector2(3, 3), Vector2(6, 6)), Color("7fb7c4"), false, 1)
