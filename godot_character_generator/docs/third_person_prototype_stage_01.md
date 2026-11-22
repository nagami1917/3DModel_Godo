# Third-person Soulslike knight prototype — Stage 1

## Stage 1 goal

This stage is a playable movement-and-camera foundation only. It adds grounded `CharacterBody3D` movement, camera-relative turning, sprinting, an over-the-shoulder `SpringArm3D` camera, and placeholder idle/walk/run blending. Combat, health/stamina, dodge, enemy AI, checkpoint, and combat UI are deliberately deferred to later stages.

The knight is an original, runtime-built low-poly armor proxy. It is made from separate helmet, cuirass, tassets, greaves, shield, and sword shapes so the placeholder reads as a knight. It is not the final production character mesh and has no skeleton or skin weights.

## Open and run

1. Open `godot_character_generator/project.godot` in Godot 4.3 or a compatible Godot 4 release.
2. Let the FileSystem scan the new `prototype/` scenes and scripts.
3. Press **F6** to run `prototype/scenes/stage_01_player_test.tscn`, or **F5** to run the project main scene (which is set to the same test scene).
4. Click inside the game window to capture the mouse. Press **Esc** to release it; click again to recapture.
5. Walk around the stone test arena and approach its pillars/walls to test the SpringArm camera collision.

This stage does not require the .NET SDK; all prototype scripts are GDScript.

## Scene and node hierarchy

```text
Stage01PlayerTest (Node3D)
├── WorldEnvironment
├── DirectionalLight3D
├── KnightPlayer (instance of knight_player.tscn)
│   ├── CollisionShape3D (CapsuleShape3D)
│   ├── VisualRoot (knight_proxy.gd builds the original armor proxy)
│   │   ├── TorsoPivot
│   │   ├── HeadPivot
│   │   ├── LeftLegPivot
│   │   │   └── KneePivot
│   │   ├── RightLegPivot
│   │   │   └── KneePivot
│   │   ├── LeftArmPivot ... Shield
│   │   └── RightArmPivot ... Sword
│   ├── AnimationPlayer (placeholder idle/walk/run clips)
│   └── AnimationTree (1D locomotion blend)
├── CameraRig (third_person_camera_rig.gd)
│   └── SpringArm3D
│       └── Camera3D
├── ArenaFloor (StaticBody3D + visual mesh)
├── Four perimeter walls and four movement-test pillars (StaticBody3D)
└── ControlsHUD
```

The VisualRoot builds its meshes at runtime so they are intentionally editable proxy geometry. The `CharacterBody3D` collider and camera rig do not depend on these visual shapes.

## Input actions and default bindings

`player_controller.gd` registers these actions in `InputMap` at runtime, so the prototype works immediately without hand-editing Project Settings:

| Action | Default binding | Stage 1 behavior |
|---|---|---|
| `move_forward` | W | Move toward the camera-facing direction |
| `move_back` | S | Move away from the camera-facing direction |
| `move_left` | A | Strafe left relative to camera yaw |
| `move_right` | D | Strafe right relative to camera yaw |
| `sprint` | Left Shift | Use sprint speed while moving |
| Mouse look | Mouse motion while captured | Orbit yaw and pitch |
| Release cursor | Esc | Show the mouse cursor |
| Capture cursor | Click game window | Capture the mouse again |

Later-stage planned bindings: Space dodge, left mouse light attack, right mouse heavy attack, Q block, Tab target lock, and E interact/rest. These are not active in Stage 1.

## Movement and camera behavior

- Movement is camera-yaw-relative. Camera pitch is flattened before calculating the movement vector, so aiming up/down never makes the knight walk vertically.
- `CharacterBody3D` acceleration/braking gives responsive starts and weighty stops. Exported walk/sprint speeds and acceleration values can be tuned on the player node.
- The knight rotates toward its desired horizontal movement direction with exponential smoothing; it does not snap-turn.
- The camera is a sibling of the player, not a child, so rotating the knight does not rotate the camera a second time.
- The SpringArm starts over the right shoulder and retracts against environment collision. Its collision mask is layer 1 and it explicitly excludes the player RID.

## Placeholder animation setup

`player_controller.gd` creates three looping clips in an `AnimationLibrary` at runtime:

- `idle`: subtle breathing and a slight head settle.
- `walk`: alternating arm/leg swing with a small knee bend and grounded torso bob.
- `run`: larger, faster limb swing and a modest forward-body bob.

An `AnimationNodeBlendSpace1D` inside an `AnimationNodeBlendTree` blends those clips based on horizontal velocity. The expected node paths are under `VisualRoot` (for example `VisualRoot/LeftLegPivot:rotation`). This makes locomotion testable without any imported animation assets.

To replace them later, import a rigged GLB, keep or map the pivot/bone track paths, create authored idle/walk/run animations in an AnimationPlayer, and bind that AnimationPlayer to the existing AnimationTree. Combat actions and transitions should be added in Stage 2, not mixed into this movement stage.

## Collision layers

| Layer | Meaning | Used by |
|---|---|---|
| 1 | Environment | Arena floor, walls, pillars; SpringArm collision mask |
| 2 | Player body | Knight capsule; player collision mask is layer 1 |

No weapon hitbox or enemy layer exists yet. The player CapsuleShape3D is approximately 2.0 m tall with radius 0.32 m, centered at Y=1.0 m. Adjust it to fit a later authored knight mesh.

## Inspector tuning

Select `KnightPlayer` in the test scene to tune:

- `walk_speed` (default 3.2 m/s)
- `sprint_speed` (default 5.4 m/s)
- `acceleration` and `braking`
- `turn_speed`
- `camera_rig_path`

Select `CameraRig` to tune mouse sensitivity, follow response, pitch limits, shoulder height, and shoulder offset. Select `SpringArm3D` to tune `spring_length`, margin, and environment collision mask.

## Testing checklist

- W/A/S/D moves relative to camera yaw, including while looking around.
- The character turns smoothly toward movement; stopping decelerates quickly but not instantly.
- Holding Shift accelerates to sprint speed; releasing it returns to walk speed.
- Mouse movement orbits around the player; pitch stays within limits.
- Esc releases the cursor and a click recaptures it.
- Camera collision shortens the arm near pillars and perimeter walls.
- Idle/walk/run blend continuously as speed changes. If the visual animation is missing, verify the `VisualRoot` pivot names and the AnimationTree parameter path `parameters/Locomotion/blend_position`.

## Stage roadmap

1. **Movement and camera (implemented here).**
2. Combat actions, action state machine, health/stamina, dodge invulnerability, and animation-gated weapon Area3D.
3. One enemy with idle/chase/attack/hurt/death states, target lock, and once-per-swing damage.
4. Small arena, checkpoint/rest/respawn, enemy reset, and combat HUD.
5. Replace or augment proxy animation/geometry with authored rigged assets; Godot visual review and tuning.
