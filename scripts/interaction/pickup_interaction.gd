class_name PickupInteraction
extends Interactable


func is_available() -> bool:
	var pickup: WorldPickup = get_parent() as WorldPickup
	return super.is_available() and pickup != null and pickup.is_available()


func execute(inventory: RuntimeInventory) -> bool:
	return is_available() and (get_parent() as WorldPickup).collect(inventory) > 0
