class_name SurfaceCellData
extends Resource
## Scenario descriptors, not measured lunar values or survival simulation coefficients.

enum Difficulty { FLAT, UNEVEN, CRATER_RIM }
enum Dust { LOW, MODERATE, HIGH }
enum Sunlight { UNSURVEYED, OPEN_SKY_ASSUMED }
enum Hazard { RESTRICTED = 1, ROUGH = 2, CRATER = 4 }

@export var terrain_type: TerrainRegion.Kind = TerrainRegion.Kind.REGOLITH
@export var difficulty: Difficulty = Difficulty.FLAT
@export var walkable: bool = true
@export var dust_tendency: Dust = Dust.MODERATE
@export var sunlight_exposure: Sunlight = Sunlight.UNSURVEYED
@export_flags("Restricted", "Rough", "Crater") var hazard_flags: int = 0
## Empty means no installed object. Reservations are not occupied building footprints.
@export var occupant_id: StringName = &""
@export var reserved_zone: StringName = &""
