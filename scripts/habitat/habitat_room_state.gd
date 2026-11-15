class_name HabitatRoomState
extends RefCounted
## Session-persistent state, separate from room presentation and inventory.

var visits: int = 0
var inspected_facilities: Dictionary[StringName, bool] = {}
var door_uses: Dictionary[StringName, int] = {}
