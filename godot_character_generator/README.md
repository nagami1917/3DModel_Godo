# Procedural Character Generator for Godot 4

This is a **separate, isolated Godot project** added to the repository because the existing checkout did not contain a Godot project or an implementation of the referenced AssetsGenerator/voxel systems. Existing repository files are preserved.

## Current implementation status

This is the first, explicitly limited generator increment—not the complete production system described in the master brief. It provides:

- Data-driven `CharacterDefinition` resources with reproducible seed/configuration fields.
- Parametric, UV-mapped, smooth ellipsoidal anatomy volumes assembled as material-grouped `ArrayMesh` surfaces.
- Humanoid, quadruped, winged, serpentine, and custom-fallback preview profiles.
- Reusable lightweight PBR material constructors.
- A basic optional capsule-based `CharacterBody3D` wrapper.
- Early mesh/scene validation with critical errors, warnings, and optimization notes.
- An editor dock for preview, validation, and save-as-new actor/definition scenes; it refuses to overwrite existing files.

**Visual and technical limits:** models are procedural blockouts made from overlapping parametric volumes, not finished realistic anatomy. They have no production skeleton, skin weights, animation, detailed hands/face, authored textures, equipment, advanced collision, or GLB exporter. The validator reports this limitation instead of claiming animation-ready success. For production-quality realistic characters, use licensed/authored source meshes and extend the pipeline to preserve their meshes and materials.

## Open in Godot

1. Open `godot_character_generator/project.godot` with Godot 4.3 or a compatible Godot 4 release.
2. Allow the editor to scan the project; the plugin is enabled in `project.godot` and adds a **Character Generator** tab to the bottom panel.
3. Enter a name, category, height, seed, and detail. Use **Preview**, **Validate**, or **Save actor**.
4. New output is written beneath `res://generated/characters/<character_id>/`. Existing scene/definition files are never replaced automatically.

The generated actor uses a root `CharacterBody3D`, a visual child, and (when enabled) a `CollisionShape3D` capsule. Collision is a gameplay approximation and should be reviewed against the final art.

## Smoke test

When Godot 4 is installed, run the basic deterministic generation/mesh/collision smoke test with:

```sh
godot --headless --path godot_character_generator --script res://tests/smoke_test.gd
```

The test checks humanoid mesh output, same-seed vertex reproducibility, actor collision validation, and quadruped dispatch. It does not replace editor import, visual inspection, resource save/reopen, or rig/animation/export testing.

## Third-person knight prototype — Stage 1

The project now opens into a small movement test scene with an original low-poly knight proxy, camera-relative `CharacterBody3D` movement, Shift sprinting, a mouse-controlled over-the-shoulder `SpringArm3D` camera, and runtime-generated placeholder idle/walk/run animations blended by `AnimationTree`.

Run the project with **F5**, or run `prototype/scenes/stage_01_player_test.tscn` with **F6**. Use WASD, Shift, mouse look, Esc to release the cursor, and click to recapture. The prototype is deliberately staged: combat, health/stamina, dodge, enemies, checkpoints, and their UI are not implemented in Stage 1.

See [`docs/third_person_prototype_stage_01.md`](docs/third_person_prototype_stage_01.md) for the hierarchy, controls, collision layers, animation setup, Inspector settings, and testing checklist.

## Validation status

No Godot executable was installed in the authoring environment, so editor import, script parsing by Godot, rendering inspection, resource round-trip, and runtime tests have **not** been performed. GDScript files were parsed/formatted with `gdtoolkit`; runtime API compatibility must still be verified in Godot before treating this project as tested.
