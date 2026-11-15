class_name MenuStarfield
extends Node2D
## Deterministic star field for the title scene. Stars are one or two pixel squares drawn
## once; a few separate stars twinkle through looping tweens. No textures are generated.

@export var area: Rect2 = Rect2(-40, -20, 1040, 250)
@export var star_count: int = 300
@export var twinkle_count: int = 18
@export var star_seed: int = 20261115

const COLORS: Array[Color] = [Color("dce4e5"), Color("adb9c0"), Color("78b7c4"), Color("758692"), Color("f4f6f2")]

var _stars: Array[Array] = []


func _ready() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = star_seed
	for index: int in star_count:
		var at := Vector2(floorf(random.randf_range(area.position.x, area.end.x)), floorf(random.randf_range(area.position.y, area.end.y)))
		# Fewer and dimmer stars toward the horizon, where the sunlit ridge would wash them out.
		var height: float = (at.y - area.position.y) / area.size.y
		if random.randf() < height * 0.5:
			continue
		var bright: bool = random.randf() < 0.16
		var color: Color = COLORS[random.randi_range(0, COLORS.size() - 1)]
		color.a = random.randf_range(0.6, 1.0) * (1.0 - height * 0.35)
		_stars.append([Rect2(at, Vector2(2, 2) if bright else Vector2(1, 1)), color])
	for index: int in twinkle_count:
		var star := ColorRect.new()
		star.name = "Twinkle%d" % index
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star.color = COLORS[random.randi_range(0, 2)]
		star.size = Vector2(2, 2) if random.randf() < 0.4 else Vector2(1, 1)
		star.position = Vector2(floorf(random.randf_range(area.position.x, area.end.x)), floorf(random.randf_range(area.position.y, area.position.y + area.size.y * 0.75)))
		add_child(star)
		if not UiMotion.reduced:
			var tween: Tween = star.create_tween().set_loops()
			var period: float = random.randf_range(2.4, 5.5)
			tween.tween_interval(random.randf_range(0.0, 2.0))
			tween.tween_property(star, "modulate:a", 0.15, period * 0.5)
			tween.tween_property(star, "modulate:a", 1.0, period * 0.5)
	queue_redraw()


func _draw() -> void:
	for star: Array in _stars:
		draw_rect(star[0], star[1])
