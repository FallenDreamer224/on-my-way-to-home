@tool
class_name WorldProp
extends Node2D
## Complete native sprite canvas positioned relative to the parent's ground point.

@export var appearance: PropAppearance:
	set(value):
		appearance = value
		if is_node_ready():
			_refresh()

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	sprite.visible = appearance != null and appearance.is_valid()
	sprite.texture = appearance.texture if sprite.visible else null
	sprite.centered = false
	sprite.offset = -Vector2(appearance.ground_anchor) if sprite.visible else Vector2.ZERO
