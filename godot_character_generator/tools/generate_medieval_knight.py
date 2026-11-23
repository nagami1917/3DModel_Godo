"""Build a static, stylized medieval knight GLB.

The knight uses the proportions and readable low-poly outfit language of the
user-provided Quaternius Modular Character Outfits - Fantasy reference, with the
existing wanderer as a scale/layout baseline. Its armor, shield and equipment
are procedural and original; no reference mesh or texture is bundled.

Requires: python -m pip install numpy trimesh
Run from repository root:
  python godot_character_generator/tools/generate_medieval_knight.py
"""
from __future__ import annotations

from pathlib import Path
import copy
import math

import numpy as np
import trimesh
from trimesh.visual.material import PBRMaterial
from trimesh.visual.texture import TextureVisuals

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "characters" / "medieval_knight" / "medieval_knight.glb"
SEGMENTS = 14

PALETTE = {
    "tunic": PBRMaterial(name="Deep royal blue wool", baseColorFactor=[34, 52, 82, 255], metallicFactor=0.0, roughnessFactor=0.95),
    "surcoat": PBRMaterial(name="Oxblood red surcoat", baseColorFactor=[112, 38, 42, 255], metallicFactor=0.0, roughnessFactor=0.92),
    "trousers": PBRMaterial(name="Charcoal wool chausses", baseColorFactor=[57, 54, 52, 255], metallicFactor=0.0, roughnessFactor=0.96),
    "leather": PBRMaterial(name="Dark harness leather", baseColorFactor=[65, 41, 29, 255], metallicFactor=0.0, roughnessFactor=0.84),
    "wood": PBRMaterial(name="Dark oak shield core", baseColorFactor=[76, 48, 31, 255], metallicFactor=0.0, roughnessFactor=0.88),
    "skin": PBRMaterial(name="Warm skin", baseColorFactor=[166, 112, 79, 255], metallicFactor=0.0, roughnessFactor=0.8),
    "steel": PBRMaterial(name="Worn forged steel", baseColorFactor=[127, 139, 140, 255], metallicFactor=0.78, roughnessFactor=0.38),
    "iron": PBRMaterial(name="Dark iron fittings", baseColorFactor=[65, 73, 74, 255], metallicFactor=0.72, roughnessFactor=0.49),
    "chainmail": PBRMaterial(name="Riveted chainmail", baseColorFactor=[92, 100, 99, 255], metallicFactor=0.62, roughnessFactor=0.61),
    "gold": PBRMaterial(name="Aged brass and gold", baseColorFactor=[160, 122, 52, 255], metallicFactor=0.7, roughnessFactor=0.43),
    "heraldry": PBRMaterial(name="Natural linen heraldry", baseColorFactor=[210, 191, 145, 255], metallicFactor=0.0, roughnessFactor=0.94),
    "eye": PBRMaterial(name="Dark visor slit", baseColorFactor=[22, 25, 27, 255], metallicFactor=0.0, roughnessFactor=0.7),
    "thread": PBRMaterial(name="Linen stitching", baseColorFactor=[181, 157, 111, 255], metallicFactor=0.0, roughnessFactor=0.94),
}
PARTS: dict[str, list[trimesh.Trimesh]] = {name: [] for name in PALETTE}


def add_ellipsoid(
    material: str,
    center: tuple[float, float, float],
    radii: tuple[float, float, float],
    subdivisions: int = 2,
) -> None:
    mesh = trimesh.creation.icosphere(subdivisions=subdivisions, radius=1.0)
    mesh.apply_scale(np.asarray(radii, dtype=float))
    mesh.apply_translation(np.asarray(center, dtype=float))
    PARTS[material].append(mesh)


def add_oriented_ellipsoid(
    material: str,
    start: tuple[float, float, float],
    end: tuple[float, float, float],
    radius_x: float,
    radius_z: float,
    subdivisions: int = 2,
) -> None:
    a = np.asarray(start, dtype=float)
    b = np.asarray(end, dtype=float)
    direction = b - a
    length = float(np.linalg.norm(direction))
    if length < 1e-6:
        return
    mesh = trimesh.creation.icosphere(subdivisions=subdivisions, radius=1.0)
    mesh.apply_scale([radius_x, length * 0.5 + radius_x * 0.55, radius_z])
    mesh.apply_transform(trimesh.geometry.align_vectors([0.0, 1.0, 0.0], direction / length))
    mesh.apply_translation((a + b) * 0.5)
    PARTS[material].append(mesh)


def add_loft(
    material: str,
    rings: list[tuple[float, float, float, float, float]],
    sections: int = SEGMENTS,
) -> None:
    """Create a closed tapered y-up volume; ring fields are y, rx, rz, cx, cz."""
    vertices: list[list[float]] = []
    for y, rx, rz, cx, cz in rings:
        for index in range(sections):
            angle = 2.0 * math.pi * index / sections
            vertices.append([cx + rx * math.cos(angle), y, cz + rz * math.sin(angle)])
    faces: list[list[int]] = []
    for ring in range(len(rings) - 1):
        lower = ring * sections
        upper = (ring + 1) * sections
        for index in range(sections):
            following = (index + 1) % sections
            a, b = lower + index, upper + index
            c, d = lower + following, upper + following
            faces.extend([[a, b, c], [b, d, c]])
    bottom_center = len(vertices)
    vertices.append([rings[0][3], rings[0][0], rings[0][4]])
    top_center = len(vertices)
    vertices.append([rings[-1][3], rings[-1][0], rings[-1][4]])
    last_ring = (len(rings) - 1) * sections
    for index in range(sections):
        following = (index + 1) % sections
        faces.append([bottom_center, following, index])
        faces.append([top_center, last_ring + index, last_ring + following])
    PARTS[material].append(
        trimesh.Trimesh(vertices=np.asarray(vertices), faces=np.asarray(faces), process=True)
    )


def add_box(
    material: str,
    center: tuple[float, float, float],
    size: tuple[float, float, float],
) -> None:
    mesh = trimesh.creation.box(extents=size)
    mesh.apply_translation(center)
    PARTS[material].append(mesh)


def add_bar(
    material: str,
    start: tuple[float, float, float],
    end: tuple[float, float, float],
    radius: float,
    sections: int = 8,
) -> None:
    a, b = np.asarray(start, dtype=float), np.asarray(end, dtype=float)
    direction = b - a
    length = float(np.linalg.norm(direction))
    if length < 1e-6:
        return
    mesh = trimesh.creation.cylinder(radius=radius, height=length, sections=sections)
    mesh.apply_transform(trimesh.geometry.align_vectors([0.0, 0.0, 1.0], direction / length))
    mesh.apply_translation((a + b) * 0.5)
    PARTS[material].append(mesh)


def add_extruded_polygon(
    material: str,
    center: tuple[float, float, float],
    outline: list[tuple[float, float]],
    thickness: float,
) -> None:
    """Extrude a clockwise x/y outline symmetrically about center.z."""
    cx, cy, cz = center
    count = len(outline)
    front_z, back_z = cz + thickness * 0.5, cz - thickness * 0.5
    vertices = [[cx + x, cy + y, front_z] for x, y in outline]
    vertices.extend([[cx + x, cy + y, back_z] for x, y in outline])
    front_center, back_center = len(vertices), len(vertices) + 1
    vertices.extend([[cx, cy, front_z], [cx, cy, back_z]])
    faces: list[list[int]] = []
    for index in range(count):
        following = (index + 1) % count
        faces.append([front_center, following, index])
        faces.append([back_center, count + index, count + following])
        faces.append([index, following, count + following])
        faces.append([index, count + following, count + index])
    mesh = trimesh.Trimesh(vertices=np.asarray(vertices), faces=np.asarray(faces), process=True)
    PARTS[material].append(mesh)


def add_ring_belt(y_bottom: float, y_top: float) -> None:
    """Create an elliptical belt band with a real inner wall."""
    sections = 24
    outer_x, outer_z = 0.24, 0.14
    inner_x, inner_z = 0.205, 0.112
    ring_specs = [
        (y_bottom, outer_x, outer_z), (y_top, outer_x, outer_z),
        (y_bottom, inner_x, inner_z), (y_top, inner_x, inner_z),
    ]
    vertices = []
    for y, rx, rz in ring_specs:
        for index in range(sections):
            angle = 2 * math.pi * index / sections
            vertices.append([rx * math.cos(angle), y, rz * math.sin(angle)])
    faces = []
    for index in range(sections):
        following = (index + 1) % sections
        low_i, high_i = index, sections + index
        low_j, high_j = following, sections + following
        inner_low_i, inner_high_i = 2 * sections + index, 3 * sections + index
        inner_low_j, inner_high_j = 2 * sections + following, 3 * sections + following
        faces.extend([
            [low_i, high_i, low_j], [high_i, high_j, low_j],
            [inner_low_i, inner_low_j, inner_high_i], [inner_high_i, inner_low_j, inner_high_j],
            [high_i, inner_high_i, high_j], [inner_high_i, inner_high_j, high_j],
            [low_i, low_j, inner_low_i], [inner_low_i, low_j, inner_low_j],
        ])
    PARTS["leather"].append(
        trimesh.Trimesh(vertices=np.asarray(vertices), faces=np.asarray(faces), process=True)
    )


def add_shield(center: tuple[float, float, float]) -> None:
    """Build a compact heater shield and raised metal edge around its face."""
    outline = [
        (-0.205, 0.34), (0.205, 0.34), (0.225, 0.10),
        (0.17, -0.19), (0.0, -0.37), (-0.17, -0.19), (-0.225, 0.10),
    ]
    add_extruded_polygon("wood", center, outline, thickness=0.055)
    front_z = center[2] + 0.031
    points = [(center[0] + x, center[1] + y, front_z) for x, y in outline]
    for index, start in enumerate(points):
        add_bar("steel", start, points[(index + 1) % len(points)], 0.009, sections=7)
    # Simple, non-text heraldic cross and central boss.
    add_box("gold", (center[0], center[1] + 0.015, front_z + 0.012), (0.055, 0.43, 0.018))
    add_box("gold", (center[0], center[1] + 0.085, front_z + 0.014), (0.29, 0.055, 0.02))
    add_ellipsoid("steel", (center[0], center[1] + 0.015, front_z + 0.035), (0.045, 0.045, 0.025), subdivisions=1)
    add_ellipsoid("gold", (center[0], center[1] + 0.015, front_z + 0.056), (0.018, 0.018, 0.009), subdivisions=1)
    # Rear grip and two leather straps remain separate from the shield plate.
    add_bar("leather", (center[0] - 0.095, center[1] + 0.12, center[2] - 0.041), (center[0] + 0.095, center[1] + 0.12, center[2] - 0.041), 0.014)
    add_bar("leather", (center[0] - 0.095, center[1] - 0.10, center[2] - 0.041), (center[0] + 0.095, center[1] - 0.10, center[2] - 0.041), 0.014)


def build_character() -> trimesh.Scene:
    for meshes in PARTS.values():
        meshes.clear()

    # Boots, wool chausses, chainmail joints, and plate greaves.
    add_ellipsoid("trousers", (0.0, 0.84, 0.0), (0.21, 0.15, 0.12))
    for side in (-1.0, 1.0):
        hip = (side * 0.115, 0.84, 0.0)
        knee = (side * 0.145, 0.49, 0.01)
        ankle = (side * 0.145, 0.19, 0.005)
        add_oriented_ellipsoid("trousers", hip, knee, 0.10, 0.10)
        add_oriented_ellipsoid("chainmail", knee, ankle, 0.073, 0.075)
        add_ellipsoid("leather", (side * 0.145, 0.19, 0.01), (0.078, 0.06, 0.085))
        add_ellipsoid("leather", (side * 0.145, 0.105, 0.04), (0.098, 0.105, 0.16))
        add_box("leather", (side * 0.145, 0.0125, 0.04), (0.17, 0.025, 0.30))
        add_ellipsoid("steel", (side * 0.145, 0.09, 0.155), (0.067, 0.055, 0.025), subdivisions=1)
        add_ellipsoid("steel", (side * 0.145, 0.49, 0.086), (0.088, 0.07, 0.055), subdivisions=1)
        add_ellipsoid("gold", (side * 0.145, 0.49, 0.135), (0.012, 0.012, 0.008), subdivisions=1)
        add_oriented_ellipsoid("steel", (side * 0.145, 0.43, 0.083), (side * 0.145, 0.15, 0.083), 0.071, 0.043)
        for strap_y in (0.25, 0.39):
            add_bar("leather", (side * 0.145 - 0.064, strap_y, 0.112), (side * 0.145 + 0.064, strap_y, 0.112), 0.011)

    # Mail shirt and padded blue under-tunic beneath the steel cuirass.
    add_loft("chainmail", [
        (0.87, 0.215, 0.12, 0.0, 0.0),
        (0.96, 0.235, 0.135, 0.0, 0.0),
        (1.08, 0.23, 0.13, 0.0, 0.0),
    ])
    add_loft("tunic", [
        (0.88, 0.22, 0.125, 0.0, 0.0),
        (0.98, 0.235, 0.135, 0.0, 0.0),
        (1.15, 0.235, 0.135, 0.0, 0.0),
        (1.31, 0.27, 0.125, 0.0, -0.005),
        (1.40, 0.23, 0.11, 0.0, -0.005),
    ])
    add_loft("steel", [
        (1.04, 0.225, 0.14, 0.0, 0.0),
        (1.12, 0.25, 0.15, 0.0, 0.0),
        (1.32, 0.275, 0.13, 0.0, -0.005),
        (1.40, 0.235, 0.115, 0.0, -0.005),
    ])
    add_ring_belt(0.965, 1.025)
    add_box("gold", (0.0, 0.995, 0.151), (0.085, 0.072, 0.025))
    add_box("leather", (0.0, 0.995, 0.167), (0.046, 0.038, 0.012))

    # Oxblood cape and front heraldic surcoat panel.
    add_extruded_polygon(
        "surcoat", (0.0, 0.0, -0.16),
        [(-0.24, 1.39), (0.24, 1.39), (0.38, 0.52), (-0.38, 0.52)],
        thickness=0.026,
    )
    add_extruded_polygon(
        "heraldry", (0.0, 0.94, 0.161),
        [(-0.12, 0.37), (0.12, 0.37), (0.10, -0.37), (-0.10, -0.37)],
        thickness=0.018,
    )
    # Gold cross, stitched hems, and a row of small surcoat fasteners.
    add_box("gold", (0.0, 1.17, 0.177), (0.045, 0.28, 0.018))
    add_box("gold", (0.0, 1.23, 0.179), (0.20, 0.045, 0.02))
    for side in (-1.0, 1.0):
        add_bar("thread", (side * 0.095, 0.56, 0.174), (side * 0.115, 1.28, 0.174), 0.0035)
    for y in (0.70, 0.82, 0.94):
        add_ellipsoid("gold", (0.0, y, 0.18), (0.012, 0.012, 0.008), subdivisions=1)

    # Gorget, bilateral pauldrons, articulated sleeves, vambraces, and gauntlets.
    add_ellipsoid("chainmail", (0.0, 1.445, 0.0), (0.095, 0.11, 0.085))
    add_ellipsoid("steel", (0.0, 1.47, 0.015), (0.145, 0.07, 0.12))
    for side in (-1.0, 1.0):
        shoulder = (side * 0.28, 1.35, 0.0)
        elbow = (side * 0.37, 1.12, 0.015)
        wrist = (side * 0.405, 0.94, 0.045)
        hand = (side * 0.42, 0.86, 0.075)
        add_oriented_ellipsoid("tunic", shoulder, elbow, 0.085, 0.09)
        add_oriented_ellipsoid("chainmail", elbow, wrist, 0.067, 0.07)
        add_ellipsoid("steel", (side * 0.285, 1.375, -0.005), (0.14, 0.09, 0.135))
        add_ellipsoid("steel", (side * 0.37, 1.12, 0.075), (0.078, 0.075, 0.055), subdivisions=1)
        add_oriented_ellipsoid("steel", (side * 0.385, 1.09, 0.08), (side * 0.408, 0.925, 0.075), 0.058, 0.038)
        add_ellipsoid("iron", (side * 0.405, 0.945, 0.075), (0.073, 0.045, 0.063), subdivisions=1)
        add_ellipsoid("leather", hand, (0.062, 0.07, 0.054), subdivisions=1)
        add_ellipsoid("steel", (side * 0.42, 0.865, 0.119), (0.061, 0.044, 0.026), subdivisions=1)
        for finger in range(4):
            finger_x = side * (0.382 + finger * 0.022)
            add_oriented_ellipsoid(
                "steel",
                (finger_x, 0.835, 0.11),
                (finger_x + side * 0.003, 0.785, 0.105),
                0.009,
                0.011,
                subdivisions=1,
            )
        for rivet_x in (side * 0.235, side * 0.285, side * 0.335):
            add_ellipsoid("gold", (rivet_x, 1.39, 0.113), (0.009, 0.009, 0.006), subdivisions=1)
        add_box("leather", (side * 0.405, 0.96, 0.09), (0.13, 0.035, 0.025))

    # Closed steel helm with brow, narrow eye slit, nasal guard, and red crest.
    add_ellipsoid("chainmail", (0.0, 1.535, 0.0), (0.115, 0.105, 0.10))
    add_ellipsoid("steel", (0.0, 1.69, -0.005), (0.135, 0.15, 0.12))
    add_ellipsoid("steel", (0.0, 1.635, 0.02), (0.128, 0.084, 0.118))
    add_box("iron", (0.0, 1.56, 0.005), (0.22, 0.028, 0.18))
    add_box("eye", (0.0, 1.675, 0.133), (0.106, 0.014, 0.012))
    add_box("steel", (0.0, 1.701, 0.125), (0.18, 0.025, 0.03))
    add_box("steel", (0.0, 1.65, 0.141), (0.018, 0.085, 0.025))
    for side in (-1.0, 1.0):
        add_ellipsoid("steel", (side * 0.095, 1.625, 0.04), (0.045, 0.072, 0.073), subdivisions=1)
        add_ellipsoid("gold", (side * 0.119, 1.61, 0.04), (0.009, 0.009, 0.009), subdivisions=1)
    add_oriented_ellipsoid("surcoat", (0.0, 1.81, -0.035), (0.0, 1.94, -0.115), 0.034, 0.032, subdivisions=1)
    add_bar("gold", (0.0, 1.80, -0.018), (0.0, 1.86, -0.075), 0.008)

    # Sword at the right hip: rigid scabbard, crossguard, grip, and pommel.
    add_oriented_ellipsoid("leather", (0.29, 0.97, -0.015), (0.43, 0.40, -0.045), 0.034, 0.04)
    add_ellipsoid("steel", (0.43, 0.405, -0.045), (0.035, 0.035, 0.04), subdivisions=1)
    add_oriented_ellipsoid("steel", (0.29, 0.96, -0.01), (0.275, 1.105, 0.015), 0.018, 0.018, subdivisions=1)
    add_oriented_ellipsoid("leather", (0.275, 0.99, 0.015), (0.27, 1.095, 0.03), 0.014, 0.014, subdivisions=1)
    add_box("steel", (0.285, 0.965, 0.025), (0.16, 0.026, 0.035))
    add_ellipsoid("gold", (0.27, 1.115, 0.03), (0.032, 0.03, 0.03), subdivisions=1)
    for strap_y in (0.58, 0.81):
        add_bar("leather", (0.31, strap_y, -0.015), (0.43, strap_y + 0.035, -0.015), 0.012)

    # Heater shield strapped to the left forearm, with a simple gold cross.
    add_shield((-0.43, 1.07, 0.235))

    scene = trimesh.Scene(base_frame="world")
    scene.metadata.update({
        "asset_name": "Medieval Knight",
        "authoring_note": "Independent static low-poly knight. Grounded at Y=0; front faces +Z; Y-up.",
        "reference_source": "Quaternius Modular Character Outfits - Fantasy (CC0 1.0), used as style/proportion reference; geometry is original.",
        "height_m": 1.956,
        "generation_seed": 1917,
    })
    scene.graph.update(frame_to="MedievalKnight", frame_from="world", matrix=np.eye(4))
    for name, meshes in PARTS.items():
        if not meshes:
            continue
        combined = trimesh.util.concatenate(meshes)
        combined.visual = TextureVisuals(material=copy.deepcopy(PALETTE[name]))
        scene.add_geometry(
            combined,
            geom_name=f"{name}_mesh",
            node_name=f"{name}_surface",
            parent_node_name="MedievalKnight",
        )
    return scene


if __name__ == "__main__":
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    result = build_character()
    OUTPUT.write_bytes(result.export(file_type="glb"))
    loaded = trimesh.load(OUTPUT, force="scene")
    bounds = loaded.bounds
    print(f"Wrote {OUTPUT}")
    print(f"Geometry groups: {len(loaded.geometry)}")
    print(f"Bounds: {bounds.tolist()}")
    print(f"File size: {OUTPUT.stat().st_size:,} bytes")
