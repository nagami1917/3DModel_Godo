# Medieval Wanderer

A static, detailed stylized low-poly medieval traveler asset authored as a Godot 4.7-friendly GLB with a reusable actor scene wrapper.

## Design and dimensions

- **Silhouette:** hooded traveler with forest-green wool tunic, russet front panel, leather harness and pack, muted metal shoulder cap, sturdy boots, and a sheathed one-handed sword.
- **Orientation:** Y-up, front faces local +Z.
- **Origin:** centered on the ground plane at the feet.
- **Approximate bounds:** width 0.98 m (including gear), height 1.79 m, depth 0.47 m.
- **Style:** intentionally stylized low-poly blockout. The face and hands are simplified; this is not a realistic source character.

## Geometry and materials

- 11 named GLB mesh/material groups: tunic, trim, trousers, leather, skin, iron, brass, hair, eye details, linen stitching, and cloth folds.
- Approximately 13,688 vertices and 26,376 triangles across the groups.
- Detail pass adds raised cape and tabard stitching, harness seams, boot laces and eyelets, belt holes, cloth folds, shoulder rivets, a small heraldic chevron, and a wrapped sword grip.
- PBR base-color, metallic, and roughness factors are embedded in the GLB. No external textures are required; there are no baked lights or shadows. Surface variation is geometric/material-based, not texture-map detail.
- The asset is static. It has no skeleton, skin weights, animations, or independently animated equipment.

## Godot files and hierarchy

- `medieval_wanderer.glb` — reusable visual model.
- `medieval_wanderer_actor.tscn` — gameplay-ready scene wrapper:

```text
MedievalWanderer (CharacterBody3D)
├── Visual (instance of medieval_wanderer.glb)
└── GameplayCapsule (CollisionShape3D, CapsuleShape3D)
```

The wrapper's approximate capsule is 1.78 m tall with a 0.28 m radius, centered at Y=0.89 m. Collision layer and mask default to 1. Adjust the capsule to fit your game and add a controller script before using it as a moving actor.

## Import and use

1. Let Godot 4.7.2 import `medieval_wanderer.glb`.
2. Open `medieval_wanderer_actor.tscn` to inspect the asset, or instance that scene in a level.
3. If the GLB appears too small or out of frame, select the visual and press **F** to frame it.
4. Add a movement/controller script and authored rig/animations separately if this needs to be a playable character.

## Reproducible source

The low-poly source generator is `tools/generate_medieval_wanderer.py`. Rebuild with Python 3 and `pip install numpy trimesh`, then run the script from the repository root. The generated GLB was checked by reloading it with Trimesh and verifying the material groups and bounds; Godot editor import/render inspection has not been performed in this environment.
