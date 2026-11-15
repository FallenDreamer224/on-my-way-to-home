# Companion scenes

`chiwis.tscn` is the native CharacterBody2D robotic dog under `World/Entities/NPCs`. It has an 8 x 4 ground rectangle, layer 1/mask 2, native-scale real SpriteFrames and a separate CharacterArtProfile. Main configures terrain, target and mode permission after instancing. The script safely waits until configured. Default preferred/activation distances are 36/56 pixels and speed is 90 pixels/second. Terrain routing is bounded and excludes unsafe diagonal gaps; unavailable routes enter WAITING. See `docs/phase_0_6_report.md`.

T (humanoid robot found on Mars, renameable) remains deferred. The generic NPC attachment point does not imply human colonists. Keep identity/state independent from sprites and follow the Art Bible before replacing visual resources.
