class_name HabitatAirlock
extends RefCounted
## Discrete narrative interlock; no gas quantities or real procedure durations.

enum Pressure { VACUUM, PRESSURIZED, CYCLING }
var pressure: Pressure = Pressure.VACUUM
var outer_open: bool = false
var inner_open: bool = false
var suit_checked: bool = false
var dust_checked: bool = false
var _target: Pressure = Pressure.VACUUM


func open_outer() -> bool:
	if pressure != Pressure.VACUUM or inner_open:
		return false
	outer_open = true
	return true


func open_inner() -> bool:
	if pressure != Pressure.PRESSURIZED or outer_open:
		return false
	inner_open = true
	return true


func inspect() -> bool:
	if pressure == Pressure.CYCLING:
		return false
	suit_checked = true
	dust_checked = true
	return true


func begin_cycle(target: Pressure, occupied: bool) -> bool:
	if (outer_open or inner_open or pressure == Pressure.CYCLING
			or target not in [Pressure.VACUUM, Pressure.PRESSURIZED]
			or target == pressure or (occupied and (not suit_checked or not dust_checked))):
		return false
	_target = target
	pressure = Pressure.CYCLING
	return true


func finish_cycle() -> bool:
	if pressure != Pressure.CYCLING or outer_open or inner_open:
		return false
	pressure = _target
	return true


func reset_inspection() -> void:
	suit_checked = false
	dust_checked = false
