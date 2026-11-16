class_name LunarBaseAssembly
extends Node2D
## Modular visual composition and prepared geometry. No utility/airlock simulation.
@export var layout: Dictionary
var occupied: Dictionary[Vector2i,bool] = {}
var hulls: Dictionary[StringName,Node2D] = {}
var equipment: Dictionary[StringName,Node2D] = {}
var corridors: TileMapLayer
var hatch: Sprite2D
var _entry: Vector2i
var _shared_airlock: HabitatAirlock

static func cell(value: Array) -> Vector2i: return Vector2i(int(value[0]),int(value[1]))
func reserve(origin: Vector2i, cells: Array[Vector2i]) -> void:
	for at: Vector2i in cells: occupied[origin+at] = true
func _ready() -> void:
	for module: Dictionary in layout.modules:
		if module.has("exterior_parent"): continue
		var id := StringName(module.id)
		var obj: Node2D = (load("res://scenes/exterior/base_g2/hull_"+String(id)+".tscn") as PackedScene).instantiate()
		var definition: ExteriorAssetDefinition = obj.get_meta("definition")
		var at := cell(module.origin)
		obj.position = IsometricGrid.tile_to_position(at)-Vector2(definition.grid_origin)
		add_child(obj)
		hulls[id]=obj
		reserve(at,definition.occupied_cells)
	corridors = TileMapLayer.new()
	corridors.name="PressurePassages"
	corridors.position=Vector2(-32,-16)
	corridors.y_sort_enabled=true
	corridors.tile_set=load("res://resources/exterior/base_g2/pressure_passages.tres")
	add_child(corridors)
	var route_cells: Dictionary[Vector2i,bool] = {}
	for value: Array in layout.corridor_cells: route_cells[cell(value)]=true
	var body := StaticBody2D.new()
	body.name="PassageCollision"
	body.collision_layer=2
	body.collision_mask=1
	add_child(body)
	var steps: Array[Vector2i] = [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1)]
	for at: Vector2i in route_cells:
		var mask: int = 0
		for i: int in 4:
			if route_cells.has(at+steps[i]) or occupied.has(at+steps[i]): mask |= 1<<i
		corridors.set_cell(at,0,Vector2i(mask%4,mask/4))
		occupied[at]=true
		var collision := CollisionPolygon2D.new()
		collision.polygon=HabitatRoom.diamond(IsometricGrid.tile_to_position(at))
		body.add_child(collision)
	for item: Dictionary in layout.equipment: _existing(item,false)
	for item: Dictionary in layout.facades: _existing(item,true)
	_round_passages(route_cells)
	if not layout.get("compact_exterior",false): _new_connection("pressure_junction",Vector2i(-10,17))
	var crew: Dictionary
	for module: Dictionary in layout.modules:
		if module.id=="crew_airlock": crew=module
	for portal: Dictionary in crew.portals:
		if portal.id=="outer": _entry=cell(crew.origin)+cell(portal.threshold)+Vector2i(1,0)
	if layout.has("exterior_entry_cell"): _entry=cell(layout.exterior_entry_cell)
	hatch=Sprite2D.new()
	hatch.name="ExteriorHatch"
	hatch.centered=false
	hatch.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	# Wall-side sorting datum; the visible native pixels retain their mounting position.
	hatch.position=IsometricGrid.tile_to_position(_entry)+Vector2(-16,-18)
	hatch.offset=Vector2(-31,-69)
	add_child(hatch)
	show_hatch(false)
	if layout.get("entrance_only",false): hatch.hide()
	_cables()

func _existing(item: Dictionary, facade: bool) -> void:
	var id := StringName(item.id)
	var definition: ExteriorAssetDefinition=load("res://resources/exterior/"+String(id)+".tres")
	var obj: Node2D
	if facade:
		# Existing full sources remain native annex/facade sprites, independent of hull roof art.
		obj=Node2D.new()
		var sprite:=Sprite2D.new()
		sprite.centered=false
		sprite.texture=definition.texture
		sprite.offset=-Vector2(definition.ground_anchor)
		obj.add_child(sprite)
	else: obj=(load("res://scenes/exterior/"+String(id)+".tscn") as PackedScene).instantiate()
	obj.name=String(id)
	obj.set_meta("definition",definition)
	var at:=cell(item.cell)
	obj.position=IsometricGrid.tile_to_position(at)-Vector2(definition.grid_origin)
	add_child(obj)
	equipment[id]=obj
	reserve(at,definition.navigation_reserved_cells if definition.collision_enabled else definition.occupied_cells)
	if facade:
		var body:=StaticBody2D.new()
		body.collision_layer=2
		body.collision_mask=1
		var shape:=CollisionPolygon2D.new()
		shape.polygon=definition.collision_polygon
		body.add_child(shape)
		obj.add_child(body)

func entry_cell() -> Vector2i: return _entry
func _round_passages(cells: Dictionary[Vector2i,bool]) -> void:
	# Finished sprites remain independent; the batched technical atlas is an optional guide.
	corridors.hide()
	var covered: Dictionary[Vector2i,bool]={}
	var steps: Array[Vector2i]=[Vector2i.LEFT,Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN]
	# Pair along increasing grid axes independently of BFS insertion direction.
	var ordered: Array[Vector2i]=[]
	for at: Vector2i in cells:ordered.append(at)
	ordered.sort_custom(func(a: Vector2i,b: Vector2i)->bool:return a.y<b.y if a.y!=b.y else a.x<b.x)
	for at: Vector2i in ordered:
		if covered.has(at):continue
		var neighbors: Array[Vector2i]=[]
		for step: Vector2i in steps:
			if cells.has(at+step):neighbors.append(step)
		if neighbors.size()==2 and Vector2(neighbors[0]).dot(Vector2(neighbors[1]))==0:
			var offset:=Vector2i(-1 if Vector2i.LEFT in neighbors else 0,-1 if Vector2i.UP in neighbors else 0)
			_new_connection("pressure_elbow" if Vector2i.RIGHT in neighbors and Vector2i.DOWN in neighbors else "pressure_junction",at+offset)
			for y: int in 2:
				for x: int in 2:
					if cells.has(at+offset+Vector2i(x,y)):covered[at+offset+Vector2i(x,y)]=true
			continue
		if neighbors.size()>2:
			_new_connection("pressure_junction",at-Vector2i.ONE)
			covered[at]=true
			continue
		if cells.has(at+Vector2i.RIGHT) and not covered.has(at+Vector2i.RIGHT):
			_new_connection("pressure_passage",at)
			covered[at]=true;covered[at+Vector2i.RIGHT]=true
		elif cells.has(at+Vector2i.DOWN) and not covered.has(at+Vector2i.DOWN):
			_new_connection("pressure_passage_sw",at)
			covered[at]=true;covered[at+Vector2i.DOWN]=true
		else:
			_new_connection("pressure_junction",at-Vector2i.ONE)
			covered[at]=true
func _new_connection(id: String, at: Vector2i) -> void:
	var obj: Node2D=(load("res://scenes/exterior/base_g2/"+id+".tscn") as PackedScene).instantiate()
	var definition: ExteriorAssetDefinition=obj.get_meta("definition")
	obj.position=IsometricGrid.tile_to_position(at)-Vector2(definition.grid_origin)
	add_child(obj)
	obj.set_meta("asset_id",id)
	obj.set_meta("placement_cell",at)
	equipment[StringName(id+"/"+str(at))]=obj
	reserve(at,definition.occupied_cells)
	var body:=StaticBody2D.new()
	body.collision_layer=2;body.collision_mask=1
	var shape:=CollisionPolygon2D.new()
	shape.polygon=definition.footprint_polygon
	body.add_child(shape)
	obj.add_child(body)
func show_hatch(opened: bool) -> void:
	if hatch!=null: hatch.texture=load("res://assets/buildings/base_g2/pressure_hatch_"+("open" if opened else "closed")+".png")
func bind_airlock(director: HabitatDirector) -> void:
	_shared_airlock=director.airlock
	director.airlock_changed.connect(func()->void: show_hatch(_shared_airlock.outer_open))
	show_hatch(_shared_airlock.outer_open)

func _cables() -> void:
	var layer:=TileMapLayer.new()
	layer.name="UtilityCables"
	layer.z_index=-2
	layer.position=Vector2(-32,-16)
	var tiles:=TileSet.new()
	tiles.tile_shape=TileSet.TILE_SHAPE_ISOMETRIC
	tiles.tile_layout=TileSet.TILE_LAYOUT_DIAMOND_DOWN
	tiles.tile_size=Vector2i(64,32)
	for mask: int in range(1,16):
		var source:=TileSetAtlasSource.new()
		source.texture=load("res://assets/environment/interiors_g2/structure/cable_"+str(mask)+".png")
		source.texture_region_size=Vector2i(64,32)
		source.create_tile(Vector2i.ZERO)
		tiles.add_source(source,mask)
	layer.tile_set=tiles
	add_child(layer)
	var cells: Dictionary[Vector2i,bool]={}
	if layout.has("utility_cable_cells"):
		for at: Array in layout.utility_cable_cells: cells[cell(at)]=true
	else:
		# Retain the original G2 gallery trunk. Production supplies actual placement cells.
		for y: int in range(1,10): cells[Vector2i(-17,y)]=true
		for x: int in range(-19,-12): cells[Vector2i(x,9)]=true
		for x: int in range(-19,-15): cells[Vector2i(x,2)]=true
	var steps: Array[Vector2i]=[Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1)]
	for at: Vector2i in cells:
		var mask: int=0
		for i: int in 4:
			if cells.has(at+steps[i]): mask|=1<<i
		layer.set_cell(at,maxi(mask,1),Vector2i.ZERO)
