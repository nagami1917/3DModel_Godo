# Medieval Knight

A static, stylized low-poly knight built with the user-provided **Reference** Drive folder as a style baseline and the repository's wanderer as a proportion/layout baseline. The available Reference character files are Rangers and Peasants rather than knights, so this is a new procedural design—not a direct import or alteration of a source model.

## Reference and license

- **Reference folder:** [Reference](https://drive.google.com/drive/folders/1y1GXiklQQYsBQpzgUDrvG5Vj8fToEmxl)
- **Style/proportion reference:** [Male_Ranger.gltf](https://drive.google.com/file/d/1jV8ezpKWPclEh99l1GSZycilavAcC2JR/view?usp=drivesdk)
- **Modular outfit cues:** [Male_Ranger_Head_Hood.gltf](https://drive.google.com/file/d/1xOZeLVXZ5EN5ZLZ1SQZ76jgTgnFplEjv/view?usp=drivesdk) and [Male_Ranger_Acc_Pauldron.gltf](https://drive.google.com/file/d/1kyVguF0MRp0oTz-uHDXwnldBa03Ry2-X/view?usp=drivesdk)
- The folder's `License_Standard.txt` identifies Quaternius' **Modular Character Outfits - Fantasy** pack as **CC0 1.0 Universal**. The reference geometry and textures are not redistributed here.

## Design and dimensions

- **Silhouette:** closed steel helm with a crimson crest, mail shirt, blue padded under-tunic, forged-steel cuirass and bilateral pauldrons, oxblood cape, cream heraldic tabard with a simple gold cross, greaves, gauntlets, a heater shield, and a sheathed one-handed sword.
- **Orientation:** Y-up; front faces local +Z.
- **Origin:** horizontally centered at the feet; lowest geometry is at Y=0.
- **Approximate bounds:** 1.15 m wide including the shield, 1.96 m high including the helmet crest, and 0.50 m deep.
- **Style:** readable, hand-crafted low-poly geometry with muted steel, navy, oxblood, leather, and aged-gold materials. No readable heraldic text or tiny surface noise.

## Geometry and materials

- 12 named GLB mesh/material groups: tunic, surcoat/cape, trousers, leather, shield wood, steel, iron fittings, chainmail, gold, heraldry, visor slit, and stitching.
- Approximately **6,550 vertices** and **12,676 triangles** across the groups.
- Geometry is assembled from closed low-poly volumes and panels; the shield, armor pieces, gauntlets, sword, and crest are static parts of one display model.
- PBR base-color, metallic, and roughness factors are embedded in the GLB. It uses no external textures or baked lighting/shadows.
- The asset is **static**: it has no skeleton, skin weights, or animation clips. Rig and re-author the shield/sword attachments before using it as a playable character.

## Godot files and hierarchy

- `medieval_knight.glb` — reusable visual model.
- `medieval_knight_actor.tscn` — `CharacterBody3D` wrapper with an approximate 1.95 m capsule (0.30 m radius). Its capsule covers the humanoid body, not the shield's full width; tune collisions for the target game.

## Rebuild and validation

From the repository root, install Python 3 dependencies and run the generator:

```sh
python -m pip install numpy trimesh
python godot_character_generator/tools/generate_medieval_knight.py
```

The script writes and reloads the GLB with Trimesh, then reports mesh-group count and bounds. Open `godot_character_generator/project.godot` with Godot 4.3+ to import and inspect the scene. Godot editor rendering and rig/animation validation have not been performed in this environment.
