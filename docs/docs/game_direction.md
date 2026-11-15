# Approved game direction (planned, not implemented)

On My Way to Home is a native 2D isometric pixel-art survival and base-management game. Develop the Moon tutorial first: it introduces controls, construction, resource management, basic survival, and core systems. Develop the more challenging Mars campaign only after the Moon tutorial works.

Player Mode follows a single human protagonist, with direct movement, exploration, collecting resources, survival, and close-range interaction. Base Management Mode provides an overview of the same world, free camera movement/zoom, construction, resource management, infrastructure inspection, and management of equipment and power. Both modes share persistent world state; mode changes must not reset or fork it.

There are no human colonists or additional playable humans planned. Chiwis is a small robotic dog accompanying the protagonist from the Moon tutorial into Mars. T is a roughly humanoid robot discovered on Mars; T is its default name and the player can rename it. Companion behavior and rename UI are future work.

Planned survival topics are physical deterioration and health, reduced physical defenses, cardiac conditions, emotional and psychological deterioration, sleep and fatigue, environmental gravity, radiation exposure, emotional state, environmental hazards, and equipment/resource dependency. No formulas, stat ranges, damage effects, diagnoses, or final gameplay effects are established here.

This foundation does not implement terrain, movement, gameplay cameras, mode switching, interactions, inventory, resource management, construction, companions, survival, tutorials/missions, audio, or multiplayer. Future phases need individual approval. Art remains governed by `ART_BIBLE.md` and `../art/asset_standards.json`.
