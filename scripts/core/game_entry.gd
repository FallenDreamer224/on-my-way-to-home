class_name GameEntry
extends RefCounted
## Construct one fresh production Moon session; AppRoot owns attachment and teardown.
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"


static func new_game() -> Node:
	var scene := load(MAIN_SCENE_PATH) as PackedScene
	if scene == null:
		push_error("Cannot load the gameplay entry scene: " + MAIN_SCENE_PATH)
		return null
	return scene.instantiate()

