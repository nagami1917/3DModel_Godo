"""Build a static, stylized medieval wanderer GLB.

Requires: python -m pip install numpy trimesh
Run from repository root:
  python godot_character_generator/tools/generate_medieval_wanderer.py

This is a game-ready low-poly prop/character blockout, not a rigged or realistic
source character. GLB materials are simple PBR color/roughness presets.
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
OUTPUT = ROOT / "assets" / "characters" / "medieval_wanderer" / "medieval_wanderer.glb"
SEGMENTS = 16

PALETTE = {
    "tunic": PBRMaterial(name="Weathered forest wool", baseColorFactor=[55, 75, 49, 255], metallicFactor=0.0, roughnessFactor=0.94),
    "trim": PBRMaterial(name="Muted russet linen", baseColorFactor=[129, 65, 42, 255], metallicFactor=0.0, roughnessFactor=0.9),
    "trousers": PBRMaterial(name="Brown wool trousers", baseColorFactor=[75, 58, 43, 255], metallicFactor=0.0, roughnessFactor=0.96),
    "leather": PBRMaterial(name="Oiled dark leather", baseColorFactor=[71, 43, 28, 255], metallicFactor=0.0, roughnessFactor=0.82),
    "skin": PBRMaterial(name="Warm skin", baseColorFactor=[174, 119, 84, 255], metallicFactor=0.0, roughnessFactor=0.78),
    "iron": PBRMaterial(name="Forged iron", baseColorFactor=[74, 80, 79, 255], metallicFactor=0.68, roughnessFactor=0.48),
    "brass": PBRMaterial(name="Aged brass", baseColorFactor=[157, 119, 55, 255], metallicFactor=0.72, roughnessFactor=0.42),
    "hair": PBRMaterial(name="Dark chestnut hair", baseColorFactor=[49, 34, 27, 255], metallicFactor=0.0, roughnessFactor=0.9),
    "eye": PBRMaterial(name="Eyes and details", baseColorFactor=[31, 27, 24, 255], metallicFactor=0.0, roughnessFactor=0.58),
    "thread": PBRMaterial(name="Natural linen stitching", baseColorFactor=[170, 148, 107, 255], metallicFactor=0.0, roughnessFactor=0.94),
    "fold": PBRMaterial(name="Deep cloth folds", baseColorFactor=[39, 53, 36, 255], metallicFactor=0.0, roughnessFactor=0.96),
}
PARTS: dict[str, list[trimesh.Trimesh]] = {name: [] for name in PALETTE}


def add_ellipsoid(material: str, center: tuple[float, float, float], radii: tuple[float, float, float], subdivisions: int = 2) -> None:
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
    rotation = trimesh.geometry.align_vectors([0.0, 1.0, 0.0], direction / length)
    mesh.apply_transform(rotation)
    mesh.apply_translation((a + b) * 0.5)
    PARTS[material].append(mesh)


def add_loft(material: str, rings: list[tuple[float, float, float, float, float]], sections: int = SEGMENTS) -> None:
    """Create a closed, y-up tapered body loft. Ring fields: y, rx, rz, cx, cz."""
    vertices: list[list[float]] = []
    for y, rx, rz, cx, cz in rings:
        for i in range(sections):
            angle = 2.0 * math.pi * i / sections
            vertices.append([cx + rx * math.cos(angle), y, cz + rz * math.sin(angle)])
    faces: list[list[int]] = []
    for ring in range(len(rings) - 1):
        lower = ring * sections
        upper = (ring + 1) * sections
        for i in range(sections):
            j = (i + 1) % sections
            a, b, c, d = lower + i, upper + i, lower + j, upper + j
            faces.extend([[a, b, c], [b, d, c]])
    bottom_center = len(vertices)
    y0 = rings[0][0]
    vertices.append([rings[0][3], y0, rings[0][4]])
    top_center = len(vertices)
    yn = rings[-1][0]
    vertices.append([rings[-1][3], yn, rings[-1][4]])
    first_ring = 0
    last_ring = (len(rings) - 1) * sections
    for i in range(sections):
        j = (i + 1) % sections
        faces.append([bottom_center, first_ring + j, first_ring + i])
        faces.append([top_center, last_ring + i, last_ring + j])
    mesh = trimesh.Trimesh(vertices=np.asarray(vertices), faces=np.asarray(faces), process=True)
    PARTS[material].append(mesh)


def add_box(material: str, center: tuple[float, float, float], size: tuple[float, float, float]) -> None:
    mesh = trimesh.creation.box(extents=size)
    mesh.apply_translation(center)
    PARTS[material].append(mesh)


def add_bar(material: str, a: tuple[float, float, float], b: tuple[float, float, float], radius: float) -> None:
    start, end = np.asarray(a, dtype=float), np.asarray(b, dtype=float)
    delta = end - start
    length = float(np.linalg.norm(delta))
    if length < 1e-6:
        return
    mesh = trimesh.creation.cylinder(radius=radius, height=length, sections=10)
    mesh.apply_transform(trimesh.geometry.align_vectors([0.0, 0.0, 1.0], delta / length))
    mesh.apply_translation((start + end) * 0.5)
    PARTS[material].append(mesh)


def add_stitch_line(
    start: tuple[float, float, float],
    end: tuple[float, float, float],
    count: int,
    material: str = "thread",
    size: float = 0.005,
) -> None:
    """Place spaced, raised stitch dashes along a seam or strap edge."""
    a = np.asarray(start, dtype=float)
    b = np.asarray(end, dtype=float)
    for index in range(count):
        t = (index + 0.5) / count
        point = a + (b - a) * t
        add_ellipsoid(material, tuple(point), (size, size * 0.65, size * 0.45), subdivisions=1)


def add_belt(y0: float, y1: float, outer: tuple[float, float], inner: tuple[float, float], sections: int = 24) -> None:
    """Closed elliptical belt band, with both inner and outer walls."""
    vertices: list[list[float]] = []
    ring_specs = [
        (y0, outer[0], outer[1]), (y1, outer[0], outer[1]),
        (y0, inner[0], inner[1]), (y1, inner[0], inner[1]),
    ]
    for y, rx, rz in ring_specs:
        for i in range(sections):
            t = 2 * math.pi * i / sections
            vertices.append([rx * math.cos(t), y, rz * math.sin(t)])
    faces: list[list[int]] = []
    for i in range(sections):
        j = (i + 1) % sections
        lo_i, hi_i = i, sections + i
        lo_j, hi_j = j, sections + j
        in_lo_i, in_hi_i = 2 * sections + i, 3 * sections + i
        in_lo_j, in_hi_j = 2 * sections + j, 3 * sections + j
        faces.extend([
            [lo_i, hi_i, lo_j], [hi_i, hi_j, lo_j],
            [in_lo_i, in_lo_j, in_hi_i], [in_hi_i, in_lo_j, in_hi_j],
            [hi_i, in_hi_i, hi_j], [in_hi_i, in_hi_j, hi_j],
            [lo_i, lo_j, in_lo_i], [in_lo_i, lo_j, in_lo_j],
        ])
    PARTS["leather"].append(trimesh.Trimesh(vertices=np.asarray(vertices), faces=np.asarray(faces), process=True))


def add_cape() -> None:
    """Thin closed trapezoid cape behind the shoulders."""
    verts = np.asarray([
        [-0.24, 1.39, -0.135], [0.24, 1.39, -0.135],
        [0.37, 0.49, -0.19], [-0.37, 0.49, -0.19],
        [-0.24, 1.39, -0.175], [0.24, 1.39, -0.175],
        [0.37, 0.49, -0.23], [-0.37, 0.49, -0.23],
    ])
    faces = np.asarray([
        [0, 1, 2], [0, 2, 3], [5, 4, 7], [5, 7, 6],
        [4, 0, 3], [4, 3, 7], [1, 5, 6], [1, 6, 2],
        [4, 5, 1], [4, 1, 0], [3, 2, 6], [3, 6, 7],
    ])
    PARTS["tunic"].append(trimesh.Trimesh(vertices=verts, faces=faces, process=True))


def add_tabard() -> None:
    """Front hanging russet panel, tapered toward the hem."""
    verts = np.asarray([
        [-0.105, 0.99, 0.151], [0.105, 0.99, 0.151],
        [0.075, 0.59, 0.151], [-0.075, 0.59, 0.151],
        [-0.105, 0.99, 0.128], [0.105, 0.99, 0.128],
        [0.075, 0.59, 0.128], [-0.075, 0.59, 0.128],
    ])
    faces = np.asarray([
        [0, 1, 2], [0, 2, 3], [5, 4, 7], [5, 7, 6],
        [4, 0, 3], [4, 3, 7], [1, 5, 6], [1, 6, 2],
        [4, 5, 1], [4, 1, 0], [3, 2, 6], [3, 6, 7],
    ])
    PARTS["trim"].append(trimesh.Trimesh(vertices=verts, faces=faces, process=True))


def build_character() -> trimesh.Scene:
    # Reset module-level material buckets so repeated calls remain reproducible.
    for meshes in PARTS.values():
        meshes.clear()

    # Legs, trousers, and sturdy turned-up boots.
    add_ellipsoid("trousers", (0.0, 0.83, 0.0), (0.205, 0.16, 0.12))
    for side in (-1.0, 1.0):
        hip = (side * 0.115, 0.84, 0.0)
        knee = (side * 0.14, 0.49, 0.015)
        ankle = (side * 0.145, 0.19, 0.0)
        add_oriented_ellipsoid("trousers", hip, knee, 0.105, 0.10)
        add_ellipsoid("leather", (side * 0.14, 0.49, 0.015), (0.083, 0.075, 0.09))
        add_oriented_ellipsoid("trousers", knee, ankle, 0.072, 0.077)
        add_ellipsoid("leather", (side * 0.145, 0.20, 0.005), (0.08, 0.055, 0.083))
        add_ellipsoid("leather", (side * 0.145, 0.115, 0.045), (0.098, 0.105, 0.16))
        add_box("leather", (side * 0.145, 0.027, 0.045), (0.17, 0.025, 0.32))
        add_box("iron", (side * 0.145, 0.175, -0.025), (0.13, 0.035, 0.055))
        for lace_y in (0.18, 0.21, 0.24):
            add_bar(
                "thread",
                (side * 0.145 - 0.034, lace_y, 0.186),
                (side * 0.145 + 0.034, lace_y + 0.012, 0.186),
                0.0045,
            )
            for eyelet_x in (-0.042, 0.042):
                add_ellipsoid(
                    "brass",
                    (side * 0.145 + eyelet_x, lace_y, 0.185),
                    (0.006, 0.006, 0.004),
                    subdivisions=1,
                )

    # Tunic shell, shoulders, collar and weathered cape.
    add_loft("tunic", [
        (0.88, 0.205, 0.115, 0.0, 0.0),
        (0.96, 0.225, 0.13, 0.0, 0.0),
        (1.08, 0.205, 0.115, 0.0, 0.0),
        (1.25, 0.245, 0.125, 0.0, 0.0),
        (1.37, 0.31, 0.12, 0.0, -0.005),
        (1.42, 0.245, 0.105, 0.0, -0.005),
    ])
    add_cape()
    add_loft("trim", [
        (1.385, 0.105, 0.088, 0.0, 0.0),
        (1.425, 0.095, 0.082, 0.0, 0.0),
    ], sections=12)
    add_belt(0.975, 1.035, (0.232, 0.137), (0.202, 0.111))
    add_box("brass", (0.0, 1.005, 0.142), (0.085, 0.065, 0.025))
    add_box("leather", (0.0, 1.005, 0.157), (0.045, 0.032, 0.012))
    add_tabard()
    for y in (0.70, 0.79, 0.88):
        add_ellipsoid("brass", (0.0, y, 0.166), (0.014, 0.014, 0.008), subdivisions=1)

    # Chest strap, travel pack and small field supplies.
    add_oriented_ellipsoid("leather", (-0.23, 1.37, 0.04), (0.18, 1.06, 0.07), 0.024, 0.018, subdivisions=1)
    add_oriented_ellipsoid("leather", (0.21, 1.36, -0.02), (-0.16, 1.05, -0.025), 0.022, 0.018, subdivisions=1)
    add_ellipsoid("leather", (0.0, 1.16, -0.165), (0.16, 0.22, 0.09))
    add_box("leather", (0.0, 1.12, -0.24), (0.20, 0.16, 0.035))
    add_box("brass", (0.0, 1.14, -0.262), (0.05, 0.045, 0.012))
    add_ellipsoid("trim", (0.215, 0.95, 0.09), (0.09, 0.10, 0.075))
    add_box("leather", (0.215, 0.95, 0.17), (0.12, 0.12, 0.035))

    # Visible tailoring: tabard edge stitches, harness stitches, pouch seams,
    # cape piping, belt holes, and shallow cloth folds.
    for side in (-1.0, 1.0):
        add_stitch_line(
            (side * 0.092, 0.95, 0.157),
            (side * 0.074, 0.62, 0.157),
            13,
            size=0.004,
        )
        add_stitch_line(
            (side * 0.255, 1.28, -0.185),
            (side * 0.35, 0.57, -0.225),
            20,
            size=0.004,
        )
    add_stitch_line((-0.205, 1.35, 0.065), (0.16, 1.075, 0.095), 18, size=0.004)
    add_stitch_line((0.16, 0.995, 0.19), (0.27, 0.995, 0.19), 8, size=0.0035)
    add_stitch_line((0.27, 0.995, 0.19), (0.27, 0.905, 0.19), 7, size=0.0035)
    add_stitch_line((0.27, 0.905, 0.19), (0.16, 0.905, 0.19), 8, size=0.0035)
    for x in (-0.16, -0.12, -0.08, -0.04, 0.04, 0.08, 0.12, 0.16):
        add_ellipsoid("iron", (x, 1.005, 0.139), (0.005, 0.005, 0.003), subdivisions=1)
    for side in (-1.0, 1.0):
        add_bar("fold", (side * 0.16, 0.89, 0.115), (side * 0.13, 0.79, 0.119), 0.005)
        add_bar("fold", (side * 0.18, 0.94, 0.117), (side * 0.16, 0.88, 0.12), 0.004)

    # Arms: wool sleeves, leather cuffs, exposed hands, and one iron shoulder cap.
    for side in (-1.0, 1.0):
        shoulder = (side * 0.285, 1.34, 0.0)
        elbow = (side * 0.385, 1.12, 0.015)
        wrist = (side * 0.415, 0.93, 0.035)
        hand = (side * 0.42, 0.855, 0.055)
        add_ellipsoid("tunic", shoulder, (0.105, 0.11, 0.11))
        add_oriented_ellipsoid("tunic", shoulder, elbow, 0.087, 0.09)
        add_oriented_ellipsoid("leather", elbow, wrist, 0.068, 0.072)
        add_ellipsoid("leather", (side * 0.415, 0.945, 0.035), (0.074, 0.045, 0.078))
        add_ellipsoid("skin", hand, (0.058, 0.075, 0.047))
        for finger in range(4):
            fx = side * (0.385 + 0.021 * finger)
            add_ellipsoid("skin", (fx, 0.80, 0.07), (0.011, 0.035, 0.014), subdivisions=1)
        add_oriented_ellipsoid("leather", (side * 0.39, 1.15, 0.0), (side * 0.45, 1.00, 0.02), 0.018, 0.018, subdivisions=1)
    add_ellipsoid("iron", (0.29, 1.395, -0.005), (0.125, 0.075, 0.12))
    add_ellipsoid("brass", (0.29, 1.405, 0.105), (0.027, 0.027, 0.016), subdivisions=1)
    for rivet_x, rivet_y in ((0.235, 1.40), (0.29, 1.445), (0.345, 1.40)):
        add_ellipsoid("brass", (rivet_x, rivet_y, 0.106), (0.009, 0.009, 0.006), subdivisions=1)

    # Neck, hood, face, hair, and restrained facial features facing local +Z.
    add_ellipsoid("skin", (0.0, 1.455, 0.0), (0.075, 0.09, 0.07))
    add_ellipsoid("tunic", (0.0, 1.625, -0.025), (0.13, 0.165, 0.115))
    add_ellipsoid("hair", (0.0, 1.625, -0.005), (0.094, 0.125, 0.083))
    add_ellipsoid("skin", (0.0, 1.625, 0.038), (0.092, 0.118, 0.084))
    add_ellipsoid("hair", (0.0, 1.552, 0.105), (0.063, 0.054, 0.035))
    for side in (-1.0, 1.0):
        add_ellipsoid("skin", (side * 0.096, 1.628, 0.02), (0.025, 0.04, 0.026), subdivisions=1)
        add_ellipsoid("eye", (side * 0.034, 1.65, 0.113), (0.012, 0.009, 0.007), subdivisions=1)
        add_ellipsoid("hair", (side * 0.034, 1.669, 0.111), (0.021, 0.007, 0.008), subdivisions=1)
    add_ellipsoid("skin", (0.0, 1.62, 0.123), (0.018, 0.033, 0.02), subdivisions=1)
    add_ellipsoid("eye", (0.0, 1.598, 0.117), (0.028, 0.006, 0.006), subdivisions=1)
    for side in (-1.0, 1.0):
        add_stitch_line(
            (side * 0.105, 1.705, 0.045),
            (side * 0.102, 1.565, 0.052),
            12,
            size=0.0035,
        )
    add_ellipsoid("brass", (0.0, 1.475, 0.078), (0.026, 0.028, 0.012), subdivisions=1)
    add_ellipsoid("thread", (0.0, 1.475, 0.091), (0.008, 0.008, 0.004), subdivisions=1)

    # A small stitched heraldic chevron on the tabard gives the focal point
    # detail without relying on unreadable micro-texture noise.
    add_bar("brass", (-0.035, 0.865, 0.164), (0.0, 0.825, 0.166), 0.006)
    add_bar("brass", (0.0, 0.825, 0.166), (0.035, 0.865, 0.164), 0.006)
    add_ellipsoid("thread", (0.0, 0.814, 0.168), (0.006, 0.007, 0.003), subdivisions=1)

    # A sheathed arming sword at the left hip; rigid prop, not an animated weapon.
    add_oriented_ellipsoid("leather", (-0.30, 0.97, -0.02), (-0.43, 0.39, -0.035), 0.037, 0.045)
    add_ellipsoid("iron", (-0.43, 0.395, -0.035), (0.039, 0.045, 0.047), subdivisions=1)
    add_oriented_ellipsoid("iron", (-0.30, 0.94, -0.02), (-0.285, 1.10, 0.005), 0.019, 0.018)
    add_oriented_ellipsoid("leather", (-0.294, 1.00, -0.01), (-0.285, 1.09, 0.004), 0.015, 0.015)
    for wrap in range(5):
        t = (wrap + 0.5) / 5.0
        x = -0.294 + 0.009 * t
        y = 1.00 + 0.09 * t
        z = -0.01 + 0.014 * t
        add_bar("thread", (x - 0.016, y, z + 0.012), (x + 0.016, y + 0.004, z + 0.012), 0.0025)
    add_box("iron", (-0.30, 0.965, 0.002), (0.16, 0.025, 0.03))
    for guard_x in (-0.37, -0.23):
        add_ellipsoid("brass", (guard_x, 0.965, 0.02), (0.012, 0.012, 0.009), subdivisions=1)
    add_ellipsoid("brass", (-0.285, 1.112, 0.005), (0.035, 0.035, 0.035), subdivisions=1)
    for y in (0.55, 0.79):
        add_bar("leather", (-0.39, y, -0.015), (-0.28, y + 0.04, -0.015), 0.012)

    scene = trimesh.Scene(base_frame="world")
    scene.metadata.update({
        "asset_name": "Medieval Wanderer",
        "authoring_note": "Static stylized low-poly GLB. Grounded at origin; front faces +Z; Y-up.",
        "height_m": 1.8,
        "generation_seed": 1917,
    })
    scene.graph.update(frame_to="MedievalWanderer", frame_from="world", matrix=np.eye(4))
    for name, meshes in PARTS.items():
        if not meshes:
            continue
        combined = trimesh.util.concatenate(meshes)
        combined.visual = TextureVisuals(material=copy.deepcopy(PALETTE[name]))
        scene.add_geometry(
            combined,
            geom_name=f"{name}_mesh",
            node_name=f"{name}_surface",
            parent_node_name="MedievalWanderer",
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
