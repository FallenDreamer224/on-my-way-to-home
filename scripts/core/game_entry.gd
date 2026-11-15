class_name GameEntry
extends RefCounted
## Future menu boundary: construct one fresh session; caller owns attachment and teardown.
## Main remains the project's direct startup scene during D0.
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"


static func new_game() -> Node:
	var scene := load(MAIN_SCENE_PATH) as PackedScene
	if scene == null:
		push_error("Cannot load the gameplay entry scene: " + MAIN_SCENE_PATH)
		return null
	return scene.instantiate()

