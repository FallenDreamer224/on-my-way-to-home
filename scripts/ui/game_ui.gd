class_name GameUI
extends CanvasLayer
## Composition boundary for passive HUD, reusable prompt and the existing modal inventory.

@onready var hud: GameHUD = $GameHUD
@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt
@onready var inventory_window: InventoryWindow = $InventoryWindow


func configure(items: RuntimeInventory, detector: InteractionDetector, modes: GameplayModeCoordinator, camera: BaseManagementCameraRig, show_development: bool) -> void:
	inventory_window.configure(items)
	interaction_prompt.configure(detector)
	interaction_prompt.notice_requested.connect(_interaction_notice)
	hud.configure(modes, camera, inventory_window, show_development)


func notify(text: String, duration: float = 3.5) -> bool:
	return hud.notifications.post_message(text, duration)


func refresh_bindings() -> void:
	hud.refresh_bindings()
	interaction_prompt.refresh_prompt()


func _interaction_notice(text: String) -> void:
	notify(text)
