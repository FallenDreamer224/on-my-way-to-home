class_name CharacterArtProfile
extends Resource
## Reviewed source textures and source-pixel foot anchors, independent of physical shape.

@export var frames: SpriteFrames
@export var default_anchor: Vector2 = Vector2(32, 56)
@export var foot_anchors: Dictionary[StringName, PackedVector2Array] = {}
