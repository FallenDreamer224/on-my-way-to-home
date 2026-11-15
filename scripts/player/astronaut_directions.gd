class_name AstronautDirections
extends RefCounted

const NAMES: Array[StringName] = [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const VECTORS: Array[Vector2] = [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]


static func from_vector(direction: Vector2) -> StringName:
	return NAMES[posmod(roundi(direction.angle() / (PI / 4.0)) + 2, 8)]
