class_name HabitatRoom
extends Node2D
## Reusable cutaway compartment, native floors, solid walls/cabinets and entry actions.

static var _floor_art: TileSet
var definition: Dictionary
var state: HabitatRoomState
var region: HabitatRoomRegion
var actions: Dictionary[StringName, HabitatAction] = {}
var _handler: Callable
var _wall_cells: Array[Vector2i] = []


static func cell(value: Array) -> Vector2i:
	return Vector2i(int(value[0]), int(value[1]))


func setup(data: Dictionary, saved: HabitatRoomState, handler: Callable) -> void:
	definition = data
	state = saved
	_handler = handler
	region = HabitatRoomRegion.new()
	region.origin = Vector2i.ZERO
	region.size = cell(data.size)
	for fixture: Dictionary in data.facilities:
		region.blocked_cells.append(cell(fixture.fixture))
	for extra: Array in data.extra_blocked_cells:
		region.blocked_cells.append(cell(extra))
	$Floor.region = region
	$Floor.terrain_art = floor_art()


static func floor_art() -> TileSet:
	if _floor_art != null:
		return _floor_art
	var textures: Array[Texture2D] = []
	for color: Color in [Color("354954"), Color("405661"), Color("253640"), Color("53626a")]:
		var image := Image.create(64, 32, false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		for y: int in 32:
			for x: int in 64:
				var distance: float = absf((x + 0.5 - 32) / 32.0) + absf((y + 0.5 - 16) / 16.0)
				if distance <= 1:
					image.set_pixel(x, y, color.lightened(0.16) if distance > 0.9 else color)
		textures.append(ImageTexture.create_from_image(image))
	_floor_art = PlaceholderTerrain.create_tile_set(textures)
	return _floor_art


func _ready() -> void:
	for y: int in region.size.y:
		for x: int in region.size.x:
			var at := Vector2i(x, y)
			if not $Floor.terrain_cells.has(at):
				_wall_cells.append(at)
				var shape := CollisionPolygon2D.new()
				shape.polygon = diamond(IsometricGrid.tile_to_position(at))
				$Walls.add_child(shape)
	for facility: Dictionary in definition.facilities:
		_make_action(StringName(facility.id), String(facility.title), &"facility", cell(facility.point))
	for door: Dictionary in definition.doors:
		_make_action(StringName(door.id), String(door.title), StringName(door.destination), cell(door.point))
	var title := Label.new()
	title.text = String(definition.title).to_upper()
	title.add_theme_font_size_override("font_size", 12)
	title.position = Vector2(-96, -46)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)
	queue_redraw()


func _make_action(id: StringName, title: String, target: StringName, at: Vector2i) -> void:
	var action := make_action(StringName(definition.id), id, title, target, _handler)
	action.position = IsometricGrid.tile_to_position(at)
	add_child(action)
	actions[id] = action


static func make_action(room_id: StringName, id: StringName, title: String, target: StringName, handler: Callable) -> HabitatAction:
	var action := HabitatAction.new()
	action.room_id = room_id
	action.action_id = id
	action.destination = target
	action.display_name = title
	action.action_label = "Inspect" if target == &"facility" else "Use"
	action.selection_id = "habitat/%s/%s" % [room_id, id]
	action.handler = handler
	action.collision_layer = 8
	action.collision_mask = 0
	action.monitoring = false
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 3
	collider.shape = circle
	action.add_child(collider)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 10)
	label.position = Vector2(8, -12)
	label.modulate = Color("9bc6ce")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action.add_child(label)
	return action


static func diamond(center: Vector2) -> PackedVector2Array:
	return PackedVector2Array([center + Vector2(0, -16), center + Vector2(32, 0), center + Vector2(0, 16), center + Vector2(-32, 0)])


func _draw() -> void:
	for at: Vector2i in _wall_cells:
		var center := IsometricGrid.tile_to_position(at)
		var height: float = 14 if at in region.blocked_cells else 24
		# Front walls use low transparent cutaways so actors remain readable.
		var front: bool = at.x == region.size.x - 1 or at.y == region.size.y - 1
		var color := Color(0.3, 0.4, 0.46, 0.3) if front else Color("71818b")
		draw_colored_polygon(diamond(center), Color("24313a"))
		var side := PackedVector2Array([center + Vector2(-32, 0), center + Vector2(0, 16), center + Vector2(32, 0), center + Vector2(32, -height), center + Vector2(0, 16-height), center + Vector2(-32, -height)])
		draw_colored_polygon(side, color.darkened(0.2))
		draw_colored_polygon(diamond(center - Vector2(0, height)), color)
	for action: HabitatAction in actions.values():
		var center: Vector2 = action.position
		draw_rect(Rect2(center - Vector2(5, 5), Vector2(10, 10)), Color("74acbb"), false, 1)
