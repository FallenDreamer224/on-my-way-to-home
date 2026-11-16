extends SceneTree
## Nondestructive alpha preparation: remove connected red backdrop, retain original subject RGB.
func _initialize() -> void: run.call_deferred()
func key_color(c: Color) -> bool:
	return ((c.r>c.g*1.3 and c.r>c.b*1.1) or (c.r>c.g*1.25 and c.b>c.g*1.12)) and c.r-c.g>0.035
func run() -> void:
	var jobs: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/pixellab/source/base_g2/shell_jobs.json"))
	var output: String="res://assets/buildings/base_g2/shells/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var records: Array[Dictionary]=[]
	for job: Dictionary in jobs.jobs:
		var source: String="res://assets/pixellab/source/base_g2/shell_raw/"+String(job.asset_id)+".png"
		var raw:=Image.new()
		assert(raw.load_png_from_buffer(FileAccess.get_file_as_bytes(source))==OK)
		raw.convert(Image.FORMAT_RGBA8)
		var w: int=raw.get_width();var h: int=raw.get_height();var total: int=w*h
		var background:=PackedByteArray();background.resize(total)
		var queue:=PackedInt32Array()
		for y: int in h:
			for x: int in w:
				if (x==0 or y==0 or x==w-1 or y==h-1) and key_color(raw.get_pixel(x,y)):
					var index: int=y*w+x
					if background[index]==0:background[index]=1;queue.append(index)
		var head: int=0
		while head<queue.size():
			var n: int=queue[head];head+=1
			var x: int=n%w;var y: int=n/w
			for step: Vector2i in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
				var at:=Vector2i(x,y)+step
				if at.x<0 or at.x>=w or at.y<0 or at.y>=h:continue
				var p: int=at.y*w+at.x
				if background[p]==0 and key_color(raw.get_pixelv(at)):background[p]=1;queue.append(p)
		# Detached background rocks/marks are not parts of the pressure vessel.
		var visited:=PackedByteArray();visited.resize(total)
		var subject:=PackedInt32Array()
		for seed: int in total:
			if background[seed] or visited[seed]:continue
			var component:=PackedInt32Array([seed]);visited[seed]=1;head=0
			while head<component.size():
				var n: int=component[head];head+=1
				var x: int=n%w;var y: int=n/w
				for dy: int in range(-1,2):
					for dx: int in range(-1,2):
						var xx: int=x+dx;var yy: int=y+dy
						if xx<0 or yy<0 or xx>=w or yy>=h:continue
						var p: int=yy*w+xx
						if not background[p] and not visited[p]:visited[p]=1;component.append(p)
			if component.size()>subject.size():subject=component
		var clean:=Image.create(w,h,false,Image.FORMAT_RGBA8);clean.fill(Color.TRANSPARENT)
		for n: int in subject:clean.set_pixel(n%w,n/w,raw.get_pixel(n%w,n/w))
		var bounds:=clean.get_used_rect()
		var bottom: Array[int]=[]
		for x: int in w:
			if clean.get_pixel(x,bounds.end.y-1).a==1:bottom.append(x)
		var anchor:=Vector2i((bottom[0]+bottom[-1])/2,bounds.end.y)
		var kept: int=0
		for y: int in h:
			for x: int in w:
				if clean.get_pixel(x,y).a>0:
					assert(clean.get_pixel(x,y)==raw.get_pixel(x,y));kept+=1
		assert(clean.get_size()==raw.get_size() and kept>total/8)
		var file: String=output+String(job.asset_id)+".png"
		assert(clean.save_png(file)==OK)
		var strips: Array[Dictionary]=[]
		for x: int in range(0,w,32):
			var bottom_y: int=0
			for xx: int in range(x,mini(x+32,w)):
				for yy: int in range(bounds.position.y,bounds.end.y):
					if clean.get_pixel(xx,yy).a>0:bottom_y=maxi(bottom_y,yy+1)
			if bottom_y>0:strips.append({"region":[x,0,mini(32,w-x),h],"depth_datum_px":[x+16,bottom_y]})
		records.append({"asset_id":job.asset_id,"source_raw":source.trim_prefix("res://"),"runtime_path":file.trim_prefix("res://"),"native_size_px":[w,h],"bounds_px":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"ground_anchor_px":[anchor.x,anchor.y],"footprint":job.footprint,"retained_foreground_pixels":kept,"rgb_pixels_modified":0,"native_resampling":false,"source_sha256":FileAccess.get_sha256(source),"sha256":FileAccess.get_sha256(file),"generation_id":job.job_id,"processing_recipe":"tools/exterior/key_shell_background.gd","depth_strips":strips,"review_status":"NEEDS_VISUAL_REVIEW"})
	var file:=FileAccess.open("res://art/imports/native_shells.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"phase":"0.8G2 extended","assets":records,"rejected_provider_masks":"Ten background-removal results discarded subject pixels; preserved in source/shell_cutouts and not integrated."},"  "))
	print("PASS: five native transparent shells; every retained RGB pixel unchanged; no resizing")
	quit()
