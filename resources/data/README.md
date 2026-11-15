# Future data contract

Phase 0.7 item definitions now live in `resources/items/`; runtime slots and quantities belong to the astronaut's RuntimeInventory node. The future-definition description below remains the policy for other domains. Disk persistence is still unimplemented.

Author reusable item, resource, building, survival, tutorial/mission, and companion definitions as typed data Resources when their systems are approved. Separate immutable definitions (stable ID, display/asset references, configuration) from dynamic world state (quantities, positions, health/progression values). Save/load should version explicit state, reference definitions by stable ID, and migrate versions deliberately. Do not serialize scene-tree paths or UI/camera state as authoritative gameplay state. No gameplay definitions or persistence system are implemented yet.

Phase 0.2 adds `lunar_test_region.tres` as a terrain-only configuration: origin, size, and optional authored cell-kind dictionary. Empty cells request the deterministic test fixture; a nonempty dictionary is an explicit sparse authored map with no automatic filling. TerrainLayer works on a copy, and does not write to this shared resource. This does not implement save/load or dynamic gameplay state.
