# Medieval 3D model prompt for a Godot open-world game

Use this as the shared art direction for every model in the game. Replace **[ASSET]** with the object you want to generate; keep the rest of the medieval style consistent across assets.

## Reusable prompt

> Create **one game-ready 3D model of [ASSET]** for a **medieval open-world exploration game**. The entire design—shape, construction, materials, details, and decoration—must feel medieval and belong to the same world. Use a cohesive, grounded, hand-crafted look: rough-cut stone, aged oak, forged iron, leather, wool, and linen as appropriate. Favor earthy colors such as warm stone gray, dark wood brown, muted greens, and restrained heraldic reds or blues. Avoid modern or sci-fi forms, materials, hardware, and decoration.
>
> Make the silhouette clear and recognizable from normal gameplay distance, with readable details rather than tiny surface noise. Build a clean, efficient low-to-medium-poly asset with watertight geometry and clean topology. Avoid fragile, paper-thin parts and unnecessary hidden geometry. The model should be grounded, upright, centered at the world origin, and authored at believable real-world scale (1 unit = 1 meter). Face its front toward +Z. Do not add a display plinth.
>
> Create clean UVs and game-ready PBR textures: base color, roughness, and normal maps, plus metallic only where appropriate. Keep materials readable under real-time lighting; do not bake lighting or shadows into the base-color texture. Use consistent texel density and a single texture set where practical.
>
> Deliver a textured **glTF 2.0 / GLB** suitable for import into Godot 4. Keep moving or interchangeable parts separate only if the asset needs them. Show only the requested model: no landscape, scene, extra props, people, labels, watermarks, or background.

## Example: medieval roadside watchtower

> Create one stylized, game-ready 3D model of a medieval roadside watchtower for a medieval open-world exploration game. Build it from rough limestone and dark oak, with a compact stone base, a timber lookout platform, a simple ladder, narrow arrow slits, a small crenellated parapet, and an iron-banded wooden door. Add light moss, worn stone edges, and one faded red-and-cream cloth banner with a simple, non-readable heraldic emblem. Keep the construction believable and hand-crafted, with a clear silhouette and details visible at gameplay distance. Use muted, earthy colors and restrained weathering; avoid exaggerated fantasy shapes and anything modern or sci-fi. Make it low-to-medium poly, clean and watertight, grounded at the origin, human-scale, and facing +Z. Use clean UVs and PBR textures, and deliver a textured GLB for Godot 4. Model only the tower—no road, terrain, buildings, people, extra props, text, or background.

## Animation requirements

Not every asset needs animation. Keep static environment props, such as the watchtower, static; rig only parts that should move (for example, a gate or a hanging banner). A sword is a rigid prop and should move with the character's hand, rather than having its own attack animation.

For each **player or humanoid enemy character**, use one consistent humanoid skeleton and skin, with a neutral A-pose, clean weight painting, and named animation clips in the exported GLB. Make locomotion clips loop smoothly; keep them in place with no unintended root drift so Godot can control movement. Include this core medieval action set:

- `idle`, `walk`, `run`, `sprint`
- `jump_start`, `jump_loop`, `jump_land`
- `crouch_idle`, `crouch_walk`, `dodge_roll`
- `draw_sword`, `sheathe_sword`
- `sword_attack_1`, `sword_attack_2`, `sword_attack_3`
- `block`, `parry`, `hit_reaction`, `death`, `interact`

Add role-specific clips when needed (for example, an NPC blacksmith hammering). Keep the same skeleton, scale, and naming across clips so they can be imported and organized in Godot 4.

## Example: medieval one-handed sword

> Create one game-ready 3D model of a practical medieval arming sword for a medieval open-world game. Use a straight, double-edged steel blade, a simple crossguard, a dark leather-wrapped grip, and a solid iron pommel. Keep the design believable and hand-forged, with restrained wear and a small amount of tasteful medieval decoration; make the silhouette readable at gameplay distance. Do not make it oversized or overly ornate. Model only the sword—no hand, character, sheath, or extra props. Make it low-to-medium poly with clean geometry and UVs, and use PBR materials for worn steel, leather, and iron. Set the total length to about 1 meter. Place the origin at the center of the grip so it can attach to a character hand socket in Godot; align the blade toward local +Z and the pommel toward local -Z. Keep the sword rigid: the character's hand and arm animations drive it during attacks, blocks, and parries. Deliver a textured GLB suitable for Godot 4.

## Negative prompt

> modern, sci-fi, futuristic, plastic, chrome, firearms, industrial machinery, oversized fantasy sword, excessive ornament, excessive micro-detail, noisy surface, serrated blade, messy or non-manifold geometry, paper-thin or floating parts, baked shadows, blurry textures, random extra objects, hand, character, sheath, scenery, ground plane, display base, readable text, logo, watermark, background
