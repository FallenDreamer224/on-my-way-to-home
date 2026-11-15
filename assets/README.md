# Runtime assets

Only approved, ready-to-import runtime assets belong in the category folders. Original PixelLab exports and metadata are staged separately under `pixellab/source/`, which Godot ignores. The original root `icon.svg` remains the project icon; it is not gameplay art.

PNG import defaults for future pixel art: lossless compression, mipmaps off, no rescaling or size limit, and no automatic frame trimming. Canvas filtering inherits the project nearest setting; keep texture repeat disabled unless an asset specifically needs it. Inspect these settings after Godot imports each new asset. Commit approved `.import` sidecar settings, but never `.godot/` caches. Atlas regions, animations, and TileSets are future resources under `resources/`.

No PNG assets exist yet, so there are no per-image import settings to configure. The category contracts below are intake requirements, not a claim that future imports have already been checked.
