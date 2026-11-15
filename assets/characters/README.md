# Character assets

Read `docs/ART_BIBLE.md`, `art/asset_standards.json` and `docs/isometric_standards.md` before asset work. Phase 0.6 uses supplied Pixelorama sources: sixteen native PNG sheets under `{astronaut,chiwis}/walk/{n,ne,e,se,s,sw,w,nw}.png`. Each row contains original 64 x 64 frames, with no margins, rescaling, cropping or recoloring. Idle clips reuse frame 1; there are no duplicate idle PNGs or empty idle directories.

Phase 0.7B adds sixteen corresponding sheets under `{astronaut,chiwis}/run/`. Real profiles have 24 clips each: eight idle/walk/run directions. Existing walk PNGs, idle behavior, timing and anchors are preserved. `art/imports/pixelorama_runs.json` audits 16 run and 16 current walk sources, verifies exact run RGBA, and fingerprints all 32 legacy clips. Current walk sources render identically to the preserved PNGs, including files whose names changed since Phase 0.6. The original character manifest remains historical provenance and is unchanged. Sprint is not enabled; normal controllers still select idle/walk.

`art/imports/pixelorama_characters.json` records relative source names/hashes, layer visibility, excluded Skeleton guides, exact frame ordering, bounds, timing, alpha and per-frame anchors. Native human visible height is 51-57 pixels (the official 48-56 range is a recommendation); Chiwis is 44-55 pixels tall and stays at its original quadruped proportions. Canvas dimensions do not determine physical size. `resources/characters/*_frames.tres` stores real texture regions and timing; `*_art.tres` stores measured visual anchors. Gameplay collision is independent.

## Reproduce imports

Requires PowerShell 7, Godot 4.7.2, the installed Pixelorama 1.2.4 resource pack and the original source folders. Runtime play and normal tests do not require those external files. From the project root:

```powershell
.\tools\pixelorama\build_imports.ps1 -AnimationType run -SourceRoot 'C:\path\to\assets' -PixeloramaPack 'C:\path\to\Pixelorama.pck' -GodotPath 'C:\path\to\Godot_v4.7.2-stable_win64.exe'
# Recheck run PNGs and merge run metadata/resources, preserving walk and idle:
.\tools\pixelorama\build_imports.ps1 -AnimationType run -SkipExport -SourceRoot 'C:\path\to\assets'
.\tests\validate.ps1 -IncludeRendering
```

Defaults use the sibling `assets` source directory, Pixelorama's standard roaming installation and the existing workspace Godot executable setting. Original PXO files are never changed. The exporter hides Skeleton only in ignored project-local working copies, runs the installed Pixelorama CLI at scale 1, and records tool diagnostics. The verifier independently reconstructs nonguide RGBA cels from originals and rejects any exported pixel/order mismatch. It then regenerates SpriteFrames/art profiles and audit metadata. PNG imports are lossless with mipmaps, rescaling, premultiplication and alpha-border modification off; scene filtering is nearest.

The wrapper now defaults to `-AnimationType run`; run export reads only the authorized animations folder and never re-exports walks or resets idle. Verification merges the selected state into existing profiles and rejects changed legacy run-import fingerprints. Explicit `-AnimationType walk` retains the legacy walk/idle refresh workflow and preserves registered run clips; use it only for a separately authorized walk-art update. Inspect the resulting manifests and rerun the complete suite after any intentional replacement. Each run import records its own original FPS: astronaut SW/W are 3 FPS, other astronaut runs and all Chiwis runs are 6 FPS. No per-direction rate is silently normalized.

The installed pack emits shader/signal errors and can emit resource cleanup diagnostics at exit. These are reported as tool diagnostics, not hidden as game warnings. Unexpected errors abort exports; even accepted tool diagnostics require successful exact pixel verification. Keep working copies, logs and contact sheets under ignored `tests/output/`. Do not commit them or the external PXO files. See `docs/phase_0_6_report.md` for detailed limitations and graphical evidence. Future PixelLab requests still require explicit authorization and completed provenance metadata.
