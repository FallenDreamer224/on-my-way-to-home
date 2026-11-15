extends RefCounted
## Stable semantic signatures ignore resource serialization IDs while preserving clip behavior.


static func clip(profile: CharacterArtProfile, name: StringName) -> String:
	var frames: SpriteFrames = profile.frames
	var content: Array = [String(name), frames.get_animation_speed(name), frames.get_animation_loop(name)]
	var anchors: PackedVector2Array = profile.foot_anchors.get(name, PackedVector2Array())
	for index: int in frames.get_frame_count(name):
		var texture: AtlasTexture = frames.get_frame_texture(name, index) as AtlasTexture
		assert(texture != null)
		var anchor: Vector2 = anchors[index] if index < anchors.size() else profile.default_anchor
		content.append([texture.atlas.resource_path, texture.region.position.x, texture.region.position.y,
			texture.region.size.x, texture.region.size.y, frames.get_frame_duration(name, index), anchor.x, anchor.y])
	return JSON.stringify(content).sha256_text()
