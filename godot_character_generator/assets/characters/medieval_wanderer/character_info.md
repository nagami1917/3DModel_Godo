# Medieval Wanderer — Ranger-inspired

A static, stylized low-poly medieval traveler, updated using the **Reference** Drive folder as its character-design basis. The silhouette follows the folder's hooded ranger direction and modular outfit cues: layered cloth, leather straps, an asymmetric pauldron, boots, and compact field gear. The asset remains an independently procedural re-authoring; it does **not** embed the Drive model, its geometry, or its textures.

## Reference and license

- **Reference folder:** [Reference](https://drive.google.com/drive/folders/1y1GXiklQQYsBQpzgUDrvG5Vj8fToEmxl)
- **Primary visual/design reference:** [Male_Ranger.gltf](https://drive.google.com/file/d/1jV8ezpKWPclEh99l1GSZycilavAcC2JR/view?usp=drivesdk)
- **Modular cues:** [Male_Ranger_Head_Hood.gltf](https://drive.google.com/file/d/1xOZeLVXZ5EN5ZLZ1SQZ76jgTgnFplEjv/view?usp=drivesdk) and [Male_Ranger_Acc_Pauldron.gltf](https://drive.google.com/file/d/1kyVguF0MRp0oTz-uHDXwnldBa03Ry2-X/view?usp=drivesdk)
- The folder's `License_Standard.txt` identifies the source pack as Quaternius' **Modular Character Outfits - Fantasy**, licensed **CC0 1.0 Universal**. The source files are not redistributed in this repository.

## Design and dimensions

- **Silhouette:** cloth hood, muted forest-green tunic, russet front panel, leather harness and pack, one forged-metal shoulder cap, sturdy boots, sheathed short sword, back quiver with three arrows, and a compact bow.
- **Orientation:** Y-up; front faces local +Z.
- **Origin:** centered horizontally at the feet; lowest geometry sits at Y=0.
- **Approximate bounds:** 0.98 m wide, 1.81 m high, and 0.55 m deep, including gear.
- **Style:** readable, hand-crafted low-poly medieval outfit with restrained earthy colors. The face and hands are simplified.

## Geometry and materials

- 13 named mesh/material groups: tunic, hood, trim, trousers, leather, bow/wood, skin, iron, brass, hair, eye details, linen stitching, and cloth folds.
- Approximately **14,878 vertices** and **28,656 triangles** across the groups.
- The ranger update adds a hood frame, a strapped quiver, three fletched arrows, and a rigid yew bow. Clothing seams, boot laces, belt hardware, shoulder rivets, and the tabard chevron remain geometric details rather than texture noise.
- PBR base-color, metallic, and roughness factors are embedded in the GLB. It uses no external textures, baked lighting, or baked shadows.
- The asset is **static**: it has no skeleton, skin weights, animation clips, or independently animated equipment. Rig it before using it as a playable humanoid.

## Godot files and hierarchy

- `medieval_wanderer.glb` — reusable visual model.
- `medieval_wanderer_actor.tscn` — gameplay-ready scene wrapper:

```text
MedievalWanderer (CharacterBody3D)
├── Visual (instance of medieval_wanderer.glb)
└── GameplayCapsule (CollisionShape3D, CapsuleShape3D)
```

The wrapper's approximate capsule is 1.78 m tall with a 0.28 m radius, centered at Y=0.89 m. Collision layer and mask default to 1. Adjust the capsule to fit the final model and add a controller script before using it as a moving actor.

## Rebuild and validation

Rebuild the GLB from the repository root with Python 3 and `numpy` / `trimesh` installed:

```sh
python -m pip install numpy trimesh
python godot_character_generator/tools/generate_medieval_wanderer.py
```

The script reloads the exported GLB with Trimesh and reports its mesh groups and bounds. Open `godot_character_generator/project.godot` with Godot 4.3+ to import and inspect the scene. Godot editor rendering and animation/rig validation have not been performed in this environment.
