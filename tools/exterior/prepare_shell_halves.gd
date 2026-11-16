extends SceneTree
## Exact reversible split for the provider's background-removal area limit; never resamples.
func _initialize() -> void:
	var document: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/pixellab/source/base_g2/shell_jobs.json"))
	var folder: String="res://tests/output/phase_0_8g2_base/shell_halves/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for job: Dictionary in document.jobs:
		var im:=Image.new()
		assert(im.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/pixellab/source/base_g2/shell_raw/"+String(job.asset_id)+".png"))==OK)
		var half: int=im.get_width()/2
		var rebuilt:=Image.create(im.get_width(),im.get_height(),false,im.get_format())
		for side: int in 2:
			var region:=im.get_region(Rect2i(side*half,0,half,im.get_height()))
			assert(region.save_png(folder+String(job.asset_id)+"_"+str(side)+".png")==OK)
			rebuilt.blit_rect(region,Rect2i(Vector2i.ZERO,region.get_size()),Vector2i(side*half,0))
		assert(rebuilt.get_data()==im.get_data())
	print("PASS: five native shell images split/rejoined byte-exact in pixel space; no resampling")
	quit()
