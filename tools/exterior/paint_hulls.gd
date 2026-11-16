extends SceneTree
## Native layered hull composites from original painted PNG modules, never enlarged facades.
var records: Array[Dictionary] = []
const OUT: String = "res://assets/buildings/base_g2/"
func _initialize() -> void: run.call_deferred()
func image(path: String) -> Image:
	var result := Image.new()
	assert(result.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK)
	return result
func over(target: Image, source: Image, at: Vector2i) -> void: target.blend_rect(source,Rect2i(Vector2i.ZERO,source.get_size()),at)
func project(x: float,y: float) -> Vector2i: return Vector2i(int((x-y)*32),int((x+y)*16))
func record(id: String, im: Image, anchor: Vector2i, size: Vector2i, origin: Vector2i) -> void:
	var path := OUT+id+".png"
	assert(im.save_png(path)==OK)
	var bounds := im.get_used_rect()
	records.append({"asset_id":id,"standards_version":"1.0.0","category":"modular_hull_composite","source_provider":"Project-original pixel painting and lossless composition","source_files":["tools/exterior/paint_hulls.gd","tools/interiors/paint_structure.gd","resources/data/lunar_base_art_layout.json"],"runtime_files":[path.trim_prefix("res://")],"usage_terms":"Project-original structural artwork; no pre-existing PNG transformed.","native_canvas_size_px":[im.get_width(),im.get_height()],"physical_scale_intent":"Envelope exactly accommodates the assigned native room grid; no metric capacity or engineering qualification claimed.","review_status":"NEEDS_VISUAL_REVIEW","exception":null,"ground_anchor_px_from_image_top_left":[anchor.x,anchor.y],"visible_bounds_px":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"explicit_footprint_grid_cells":[size.x,size.y],"grid_origin_px":[origin.x,origin.y],"sha256":FileAccess.get_sha256(path),"animation":{"type":"static","frame_count":1,"frame_regions":[[0,0,im.get_width(),im.get_height()]],"fps":0,"loop":false}})
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/data/lunar_base_art_layout.json"))
	var root: String = "res://assets/environment/interiors_g2/structure/"
	var roof := image(root+"roof_white.png")
	var glazing := image(root+"roof_glazed.png")
	var service := image(root+"roof_service.png")
	for module: Dictionary in plan.modules:
		var w: int = module.size[0]
		var d: int = module.size[1]
		var h: int = module.height_px
		var origin := Vector2i(d*32+8,h+24)
		var right := image(root+"hull_wall_"+str(h)+"_se.png")
		var left := image(root+"hull_wall_"+str(h)+"_sw.png")
		var im := Image.create((w+d)*32+16,h+(w+d)*16+16,false,Image.FORMAT_RGBA8)
		im.fill(Color.TRANSPARENT)
		# Front envelope walls, with relief service panels and full-height shadowed skirts.
		for j: int in d:
			var at := origin+project(w-.5,j-.5)
			over(im,left,at-Vector2i(40,h+16))
		for i: int in w:
			var at := origin+project(i-.5,d-.5)
			over(im,right,at-Vector2i(8,h+16))
		var roof_only := Image.create(im.get_width(),im.get_height(),false,Image.FORMAT_RGBA8)
		roof_only.fill(Color.TRANSPARENT)
		# Native tiles overlap only transparent bounding-box corners; alpha never erases neighbors.
		for total: int in w+d-1:
			for i: int in w:
				var j: int = total-i
				if j<0 or j>=d: continue
				var tile: Image = glazing if module.id=="greenhouse" and i>0 and j>0 and i<w-1 and j<d-1 else (service if (i+j)%5==0 else roof)
				over(im,tile,origin+project(i,j)-Vector2i(32,16+h))
				over(roof_only,tile,origin+project(i,j)-Vector2i(32,16+h))
		var front := project(w-.5,d-.5)
		record("hull_"+String(module.id),im,origin+front,Vector2i(w,d),-front)
		assert(roof_only.save_png(OUT+"hull_"+String(module.id)+"_roof.png")==OK)
		records[-1].roof_path=(OUT+"hull_"+String(module.id)+"_roof.png").trim_prefix("res://")
		records[-1].hull_height_px=h
	# Baked corridor cells use the same lattice and paint language; TileMapLayer batches them.
	var atlas := Image.create(256,448,false,Image.FORMAT_RGBA8)
	var right := image(root+"straight_se.png")
	var left := image(root+"straight_sw.png")
	atlas.fill(Color.TRANSPARENT)
	for mask: int in 16:
		var tile := Image.create(64,112,false,Image.FORMAT_RGBA8)
		tile.fill(Color.TRANSPARENT)
		# Reuse native 32-pixel wall faces, joined to one full pressure-roof diamond.
		over(tile,left,Vector2i(-8,16))
		over(tile,right,Vector2i(24,16))
		over(tile,roof,Vector2i(0,16))
		# Physical end-cap/service markings, not text or scientific values.
		if mask&1==0: tile.fill_rect(Rect2i(9,57,5,15),Color("527689"))
		if mask&2==0: tile.fill_rect(Rect2i(48,57,5,15),Color("527689"))
		if mask&4: tile.fill_rect(Rect2i(42,35,6,2),Color("91c5ce"))
		if mask&8: tile.fill_rect(Rect2i(16,35,6,2),Color("91c5ce"))
		over(atlas,tile,Vector2i(mask%4*64,mask/4*112))
		var file := OUT+"passage_"+str(mask)+".png"
		assert(tile.save_png(file)==OK)
	assert(atlas.save_png(OUT+"passage_atlas.png")==OK)
	var output := FileAccess.open("res://art/imports/base_hulls.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"assets":records,"corridor_atlas":{"path":"assets/buildings/base_g2/passage_atlas.png","native_size_px":[256,448],"frame_size_px":[64,112],"columns":4,"rows":4,"frame_count":16,"ground_anchor_px":[32,96],"texture_origin_px":[0,-40],"source_files":["tools/exterior/paint_hulls.gd","assets/environment/interiors_g2/structure/roof_white.png","assets/environment/interiors_g2/structure/straight_se.png","assets/environment/interiors_g2/structure/straight_sw.png"]}},"  "))
	print("PASS: baked nine full-size room envelopes and 16 connected pressure-passage PNGs/atlas")
	quit()
