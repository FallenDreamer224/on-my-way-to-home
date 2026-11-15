# Windows release preparation

D2.5 creates only the ignored `builds/windows/` staging location. **No Windows export, package, upload, GitHub release or tag is made in this phase.** No export preset currently exists; export compatibility is source/resource readiness only.

## Source versus binary

The public source proposal retains scripts/scenes/resources, native textures, UID/import sidecars, standards/provenance, development tools/tests and documentation. It excludes local editor configuration, credentials, caches, generated handoff archives and test outputs.

A future playable ZIP should contain only the exported executable, its PCK/runtime dependencies as required by the selected export mode, a short player README, CREDITS and applicable engine/dependency/license notices. It must not contain project source, raw asset staging, .godot, .vscode, tests, development tools, API credentials, logs, profiles or private checkpoints.

The publisher must explicitly verify export resource filters: a .gdignore or .gitignore alone is not a complete release-archive policy. Research citations and raw source/provenance can remain outside ordinary in-game item content.

## Stable artifact name

`On-My-Way-to-Home-Demo-Windows-x64.zip`

Use that as the release asset name; a future GitHub tag provides version identity. Do not invent a release tag or download URL before approval.

## Future release gate

1. Resolve project code/art license scope, supplied character/terrain redistribution permissions, provider/input rights and temporary Godot branding.
2. Finish the frozen demo's player-facing guidance/completion and gate development fault/scenario controls. Preserve existing simulation behavior.
3. Install the matching 4.7.2 Windows export templates and configure a secrets-free export_presets.cfg. Keep signing credentials, passwords and export_credentials.cfg outside Git.
4. Export only after a separate assignment. Inspect executable/PCK contents and the final ZIP allowlist; include exact-build engine/dependency notices.
5. Test cold launch, the actual sample-to-science route, Chiwis, inventory, modal cancellation, cameras/fullscreen and restart from a clean Windows profile without the editor. Record hardware/environment actually tested.
6. Compute a SHA-256 for the final ZIP. Review the license notices, README and screenshots against that exact build.
7. Publish only with explicit authorization.

No minimum CPU/RAM/GPU or tested installation guarantee is asserted from editor validation alone. No code-signing or antivirus trust bypass is proposed.

