class_name ExteriorOcclusionGuard
extends Node
## Presentation-only cutaway when a large static hull would conceal an existing actor.
var actors: Array[Node2D]=[]
var hulls: Array[Node2D]=[]
var masks: Dictionary[int,BitMap]={}
var definitions: Dictionary[int,ExteriorAssetDefinition]={}
var original_depth: Dictionary[int,int]={}
var occluded_actor_count: int=0
func configure(assembly: LunarBaseAssembly, player: Astronaut, dog: Chiwis) -> void:
	actors=[player,dog]
	for hull: Node2D in assembly.hulls.values():
		hulls.append(hull)
		original_depth[hull.get_instance_id()]=hull.z_index
		var definition: ExteriorAssetDefinition=hull.get_meta("definition")
		definitions[hull.get_instance_id()]=definition
		var id: int=definition.texture.get_instance_id()
		if not masks.has(id):
			var bitmap:=BitMap.new()
			bitmap.create_from_image_alpha(definition.texture.get_image(),.5)
			masks[id]=bitmap
func _physics_process(_delta: float) -> void:
	occluded_actor_count=0
	for hull: Node2D in hulls:
		if not is_instance_valid(hull):continue
		var fade: bool=false
		if hull.is_visible_in_tree():
			var definition: ExteriorAssetDefinition=definitions[hull.get_instance_id()]
			var bitmap: BitMap=masks[definition.texture.get_instance_id()]
			for actor: Node2D in actors:
				if not is_instance_valid(actor) or not actor.is_visible_in_tree():continue
				var height: float=40 if actor is Astronaut else 20
				for offset: Vector2 in [Vector2(0,-height),Vector2(0,-height*.6),Vector2(-8,-height*.7),Vector2(8,-height*.7)]:
					var pixel:=Vector2i((actor.global_position+offset-hull.global_position+Vector2(definition.ground_anchor)).round())
					if not Rect2i(Vector2i.ZERO,bitmap.get_size()).has_point(pixel) or not bitmap.get_bitv(pixel):continue
					var roof: Node2D=hull.get_node("Roof")
					for strip: Sprite2D in roof.get_children():
						if strip.region_rect.has_point(Vector2(pixel)) and strip.global_position.y>=actor.global_position.y-1:fade=true
				if fade:occluded_actor_count+=1
		hull.modulate.a=.32 if fade else 1.0
		# A cutaway must reveal opaque actors rather than tint them through ghost walls.
		hull.z_index=original_depth[hull.get_instance_id()]-1 if fade else original_depth[hull.get_instance_id()]
