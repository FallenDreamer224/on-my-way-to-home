class_name InteriorModule
extends Node2D
## Reusable finished PNG construction parts; quantities, doors and physics live elsewhere.

enum Kind { WALL, CORNER, WINDOW, SERVICE, SUPPORT, DOOR, CABLE_STRAIGHT, CABLE_CORNER, CABLE_VERTICAL }
@export var kind: Kind = Kind.WALL
@export var axis: Vector2i = Vector2i(1,0)
@export var cutaway: bool = false
@export var reinforced: bool = false
@export var closed: bool = false:
	set(value):
		closed = value
		queue_redraw()
static var _textures: Dictionary[String,Texture2D] = {}

static func art(name: String) -> Texture2D:
	if not _textures.has(name): _textures[name] = load("res://assets/environment/interiors_g2/structure/"+name+".png")
	return _textures[name]

func _draw() -> void:
	var left: bool = axis.y != 0
	var suffix: String = "sw" if left else "se"
	var name: String
	var anchor := Vector2(40 if left else 8,80)
	if kind == Kind.CABLE_VERTICAL:
		name = "cable_vertical"
		anchor = Vector2(32,80)
	elif kind in [Kind.CABLE_STRAIGHT,Kind.CABLE_CORNER]:
		name = "cable_9" if kind == Kind.CABLE_CORNER else ("cable_10" if left else "cable_5")
		anchor = Vector2(32,34)
	elif kind == Kind.CORNER:
		name = "corner"
		anchor = Vector2(40,80)
	elif kind == Kind.DOOR: name = ("door_closed_" if closed else "door_open_")+suffix
	elif cutaway:
		name = "cutaway_"+suffix
		anchor.y = 8
	elif kind == Kind.WINDOW: name = "window_"+suffix
	elif kind == Kind.SERVICE: name = "service_"+suffix
	elif kind == Kind.SUPPORT or reinforced: name = "support_"+suffix
	else: name = "straight_"+suffix
	draw_texture(art(name),-anchor)
