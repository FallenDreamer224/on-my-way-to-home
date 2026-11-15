@tool
class_name PropAppearance
extends Resource
## Presentation data only. Never defines item identity, collision or walkability.

@export var texture: Texture2D
@export var ground_anchor: Vector2i


func is_valid() -> bool:
	return texture != null and ground_anchor.x >= 0 and ground_anchor.y >= 0 and ground_anchor.x < texture.get_width() and ground_anchor.y <= texture.get_height()
