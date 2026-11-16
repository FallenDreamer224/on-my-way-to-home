extends SceneTree
## Original pixel painting, baked once to PNG. No runtime image synthesis or source edits.

const OUT: String = "res://assets/environment/interiors_g2/structure/"
const COLORS: Dictionary = {"ink":Color("263746"),"deep":Color("435868"),"steel":Color("718796"),"shade":Color("a0afba"),"white":Color("d3dde2"),"light":Color("edf2f1"),"blue":Color("527689"),"cyan":Color("91c5ce"),"amber":Color("c9ae76")}
var records: Array[Dictionary] = []

func _initialize() -> void: run.call_deferred()
func blank(w: int, h: int) -> Image:
	var result := Image.create(w, h, false, Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	return result
func dot(im: Image, p: Vector2i, color: Color) -> void:
	if Rect2i(Vector2i.ZERO, im.get_size()).has_point(p): im.set_pixelv(p, color)
func line(im: Image, a: Vector2, b: Vector2, color: Color, thickness: int = 1) -> void:
	var steps: int = maxi(1, int(maxf(absf(b.x-a.x), absf(b.y-a.y))))
	for step: int in steps + 1:
		var p := Vector2i((a + (b-a) * float(step) / steps).round())
		for y: int in thickness:
			for x: int in thickness: dot(im, p + Vector2i(x, y), color)
func polygon(im: Image, points: PackedVector2Array, color: Color) -> void:
	var bounds := Rect2(points[0], Vector2.ZERO)
	for p: Vector2 in points: bounds = bounds.expand(p)
	for y: int in range(maxi(0, int(bounds.position.y)), mini(im.get_height(), int(bounds.end.y) + 1)):
		for x: int in range(maxi(0, int(bounds.position.x)), mini(im.get_width(), int(bounds.end.x) + 1)):
			if Geometry2D.is_point_in_polygon(Vector2(x+0.5,y+0.5), points): im.set_pixel(x,y,color)
func save_art(id: String, im: Image, anchor: Vector2i, category: String, footprint: Vector2i = Vector2i.ZERO) -> void:
	assert(im.save_png(OUT+id+".png") == OK)
	var used := im.get_used_rect()
	records.append({"asset_id":id,"standards_version":"1.0.0","category":category,"source_provider":"Project-original pixel painting","source_files":["tools/interiors/paint_structure.gd"],"runtime_files":[OUT.trim_prefix("res://")+id+".png"],"usage_terms":"Project-original technical art; no third-party pixels transformed; project license unchanged.","native_canvas_size_px":[im.get_width(),im.get_height()],"physical_scale_intent":"Native 64x32 diamond grid; 64-pixel wall height, explicit ground origin; no metric/pressure certification.","review_status":"NEEDS_VISUAL_REVIEW","exception":null,"ground_anchor_px_from_image_top_left":[anchor.x,anchor.y],"visible_bounds_px":[used.position.x,used.position.y,used.size.x,used.size.y],"footprint_grid_cells":[footprint.x,footprint.y],"sha256":FileAccess.get_sha256(OUT+id+".png"),"animation":{"type":"static","frame_count":1,"frame_regions":[[0,0,im.get_width(),im.get_height()]],"fps":0,"loop":false}})
func face_point(anchor: Vector2, end: Vector2, u: float, height: float) -> Vector2: return anchor + end*u + Vector2(0,-height)
func wall(kind: String, left: bool, closed: bool = false, wall_height: int = 64) -> Image:
	var low: bool = kind == "cutaway"
	var im := blank(48,24 if low else wall_height+40)
	var a := Vector2(40 if left else 8, 8 if low else wall_height+16)
	var end := Vector2(-32 if left else 32,16)
	var h: int = 8 if low else wall_height
	var f := func(u: float, v: float) -> Vector2: return face_point(a,end,u,v)
	var outline := PackedVector2Array([f.call(0,0),f.call(1,0),f.call(1,h),f.call(0,h)])
	var door: bool = kind.begins_with("door")
	if not door or closed:
		polygon(im,outline,COLORS.shade if left else COLORS.white)
		polygon(im,PackedVector2Array([f.call(.08,8),f.call(.92,8),f.call(.92,h-8),f.call(.08,h-8)]),COLORS.deep if door else (COLORS.white if left else COLORS.light))
	# Four-layer pressure-frame bevel, dark gasket and functional kick rail.
	for offset: int in 3:
		line(im,f.call(0,offset),f.call(1,offset),COLORS.ink if offset==0 else COLORS.steel)
		line(im,f.call(0,h-offset),f.call(1,h-offset),COLORS.ink if offset==0 else COLORS.light)
		line(im,f.call(float(offset)/32,0),f.call(float(offset)/32,h),COLORS.ink if offset==0 else COLORS.white)
		line(im,f.call(1.0-float(offset)/32,0),f.call(1.0-float(offset)/32,h),COLORS.ink if offset==0 else COLORS.shade)
	if low: return im
	for u: float in [.12,.88]:
		for v: float in [6.0,58.0]:
			dot(im,Vector2i(f.call(u,v)),COLORS.ink)
			dot(im,Vector2i(f.call(u,v))+Vector2i(1,-1),COLORS.light)
	if door:
		if closed:
			line(im,f.call(.5,6),f.call(.5,58),COLORS.ink)
			line(im,f.call(.22,30),f.call(.39,30),COLORS.cyan,2)
			line(im,f.call(.62,30),f.call(.8,30),COLORS.steel,2)
		elif kind == "door_open":
			line(im,f.call(.12,4),f.call(.3,4),COLORS.amber,2)
			line(im,f.call(.6,4),f.call(.82,4),COLORS.amber,2)
		return im
	if kind == "window":
		polygon(im,PackedVector2Array([f.call(.13,24),f.call(.87,24),f.call(.87,53),f.call(.13,53)]),COLORS.ink)
		polygon(im,PackedVector2Array([f.call(.2,28),f.call(.8,28),f.call(.8,50),f.call(.2,50)]),COLORS.deep)
		line(im,f.call(.22,47),f.call(.75,47),COLORS.cyan)
		line(im,f.call(.5,26),f.call(.5,52),COLORS.steel,2)
	elif kind == "service":
		polygon(im,PackedVector2Array([f.call(.17,20),f.call(.83,20),f.call(.83,53),f.call(.17,53)]),COLORS.deep)
		for v: int in range(24,49,4): line(im,f.call(.24,v),f.call(.75,v),COLORS.steel)
		line(im,f.call(.2,14),f.call(.31,14),COLORS.cyan,2)
	elif kind == "support":
		line(im,f.call(.4,0),f.call(.4,64),COLORS.deep,3)
		line(im,f.call(.36,1),f.call(.36,63),COLORS.light)
	else:
		line(im,f.call(.12,17),f.call(.88,17),COLORS.shade)
		line(im,f.call(.12,47),f.call(.88,47),COLORS.shade)
		for u: float in [.2,.5,.8]: line(im,f.call(u,23),f.call(u,42),COLORS.white if left else COLORS.shade)
	line(im,f.call(.08,10),f.call(.92,10),COLORS.blue,2)
	return im
func roof(kind: String) -> Image:
	var im := blank(64,32)
	for y: int in 32:
		for x: int in 64:
			var distance: float = absf((x+.5-32)/32.0)+absf((y+.5-16)/16.0)
			if distance <= 1:
				var c: Color = COLORS.steel if distance>.94 else COLORS.white
				if kind=="glazed": c = COLORS.ink if distance>.86 else COLORS.deep
				im.set_pixel(x,y,c)
	line(im,Vector2(2,15),Vector2(31,1),COLORS.light)
	line(im,Vector2(32,1),Vector2(60,15),COLORS.shade)
	line(im,Vector2(9,16),Vector2(31,5),COLORS.shade)
	line(im,Vector2(32,5),Vector2(54,16),COLORS.shade)
	line(im,Vector2(10,17),Vector2(31,27),COLORS.light)
	if kind=="glazed":
		line(im,Vector2(4,16),Vector2(59,16),COLORS.steel)
		line(im,Vector2(32,3),Vector2(32,29),COLORS.steel)
		line(im,Vector2(14,15),Vector2(30,7),COLORS.cyan)
	elif kind=="service":
		polygon(im,PackedVector2Array([Vector2(21,16),Vector2(32,10),Vector2(43,16),Vector2(32,22)]),COLORS.deep)
		for x: int in range(26,39,3): line(im,Vector2(x,14),Vector2(x-4,17),COLORS.steel)
	for at: Vector2i in [Vector2i(15,15),Vector2i(32,7),Vector2i(48,16),Vector2i(32,25)]: dot(im,at,COLORS.ink)
	return im
func cable(mask: int) -> Image:
	var im := blank(64,32)
	var tips: Array[Vector2] = [Vector2(16,8),Vector2(48,8),Vector2(48,24),Vector2(16,24)]
	for i: int in 4:
		if not mask & (1<<i): continue
		line(im,Vector2(32,16),tips[i],COLORS.ink,5)
		line(im,Vector2(33,17),tips[i]+Vector2.ONE,COLORS.steel,3)
		line(im,Vector2(34,18),tips[i]+Vector2(2,2),COLORS.blue)
	if mask==15:
		im.fill_rect(Rect2i(28,13,10,8),COLORS.ink)
		im.fill_rect(Rect2i(30,14,6,5),COLORS.shade)
		dot(im,Vector2i(33,16),COLORS.cyan)
	return im
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for left: bool in [false,true]:
		var suffix: String = "sw" if left else "se"
		for kind: String in ["straight","window","service","support","cutaway","door_frame","door_closed","door_open"]:
			save_art(kind+"_"+suffix,wall(kind,left,kind=="door_closed"),Vector2i(40 if left else 8,8 if kind=="cutaway" else 80),"interior_structure")
	for kind: String in ["white","glazed","service"]: save_art("roof_"+kind,roof(kind),Vector2i(32,16),"exterior_roof",Vector2i.ONE)
	for h: int in [80,96]:
		for left: bool in [false,true]: save_art("hull_wall_"+str(h)+("_sw" if left else "_se"),wall("straight",left,false,h),Vector2i(40 if left else 8,h+16),"exterior_structure")
	var corner := blank(80,104)
	corner.blend_rect(wall("support",false),Rect2i(0,0,48,104),Vector2i(32,0))
	corner.blend_rect(wall("support",true),Rect2i(0,0,48,104),Vector2i.ZERO)
	save_art("corner",corner,Vector2i(40,80),"interior_structure")
	for mask: int in range(1,16): save_art("cable_"+str(mask),cable(mask),Vector2i(32,16),"utility_connection")
	var riser:=blank(64,80)
	line(riser,Vector2(30,5),Vector2(30,75),COLORS.ink,6)
	line(riser,Vector2(31,5),Vector2(31,75),COLORS.steel,4)
	line(riser,Vector2(32,5),Vector2(32,75),COLORS.blue)
	for y: int in [8,36,68]:
		riser.fill_rect(Rect2i(26,y,10,4),COLORS.ink)
		riser.fill_rect(Rect2i(28,y,6,2),COLORS.shade)
	save_art("cable_vertical",riser,Vector2i(32,80),"utility_connection")
	var file := FileAccess.open("res://art/imports/base_structure.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"phase":"0.8G2 extended","standards_version":"1.0.0","assets":records},"  "))
	print("PASS: painted %d original native PNG components; no input image modified" % records.size())
	quit()
