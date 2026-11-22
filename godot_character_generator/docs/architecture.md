# Architecture and staged roadmap

## Repository baseline

The repository baseline consists of the shared model-generation art prompt and a one-line README. There is no `project.godot`, `AssetsGenerator` codebase, JavaScript voxel pipeline, source model, exporter, or test suite in this checkout. No existing project dependencies or rendering settings needed migration. The global prompt specifies Godot 4 and GLB for model interchange; the new standalone project targets Godot 4.3-compatible GDScript APIs and GL Compatibility rendering.

## Integration choice

`godot_character_generator/` is intentionally independent of the repository root. This avoids inventing integration points or changing a nonexistent pipeline. Future assets and tools can be added within this project or bridged deliberately once the original generator/source data is present.

## Modules implemented in increment one

- `scripts/data/character_definition.gd`: serializable configuration and deterministic seed.
- `scripts/generation/parametric_mesh_builder.gd`: UV-mapped, normal-generated mesh surfaces assembled by material group.
- `scripts/generation/material_library.gd`: reusable PBR material factories.
- `scripts/generation/character_generator.gd`: dispatch and proportioned humanoid blockout construction.
- `scripts/generation/creature_generator.gd`: separate initial profiles for quadruped, winged, serpentine, and custom fallback creatures.
- `scripts/generation/scene_assembler.gd`: gameplay actor hierarchy and simplified capsule collision.
- `scripts/validation/asset_validator.gd`: basic mesh/material/collision checks and honest warnings.
- `addons/procedural_character_generator/`: editor dock with preview viewport and save-new-only workflow.

## Roadmap and boundaries

1. **Foundation (implemented, unverified in Godot):** isolated project, definition, geometry/material baseline, creature dispatch, collision wrapper, basic validation, editor dock.
2. **Anatomy and source assets:** replace/augment overlapping volume blockouts with swept/lofted anatomy and imported authored source mesh support; review silhouette from multiple views.
3. **Materials:** reusable species presets, texture resources, procedural variation and texture budget controls.
4. **Rigging:** humanoid and species-specific profiles, rest-pose validation, source-mesh skinning, attachment points.
5. **Animation:** validated authored clips and AnimationTree/state blending; procedural placeholder bone motion is not a substitute.
6. **Equipment:** bone sockets and replaceable modular equipment scenes.
7. **Editor workflow:** richer configuration, safe previews, reports, output controls, and explicit replacement/export actions.
8. **Export/testing:** GLB export, automated headless/editor tests, import round-trip, performance budgets, visual review.

## Compatibility and validation notes

Godot was not installed, so APIs and script syntax could only be reviewed statically. Godot editor import is the first required validation step. The current validator intentionally does not assert valid skeletons, skin weights, UV quality, animation tracks, GLB export, or disconnected components; those checks should be added alongside the features that provide inspectable data.
