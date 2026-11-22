class_name ProceduralCreatureGenerator
extends RefCounted

const MeshBuilder = preload("res://scripts/generation/parametric_mesh_builder.gd")
const Materials = preload("res://scripts/generation/material_library.gd")


## Extensible first-pass creature archetypes. These outputs are clearly marked as
## procedural previews; production anatomy, skinning, and species-specific detail
## require authored source meshes or later specialized generators.
static func generate(definition: CharacterDefinition) -> Node3D:
	if definition == null:
		return null
	var rng := definition.get_seeded_rng()
	var h := definition.normalized_height() * rng.randf_range(0.98, 1.02)
	var detail := definition.normalized_detail()
	var body_color := definition.skin_color
	if definition.species.to_lower() in ["wolf", "bear", "boar", "fox"]:
		body_color = definition.secondary_color
	var body_material := Materials.create_organic(body_color)
	var accent_material := Materials.create_organic(definition.accent_color, 0.7)
	var groups: Array[Dictionary] = [{"parts": []}, {"parts": []}]
	var body_parts: Array = groups[0]["parts"]
	var accent_parts: Array = groups[1]["parts"]
	var materials: Array[Material] = [body_material, accent_material]
	match definition.category:
		CharacterDefinition.Category.QUADRUPED:
			_build_quadruped(body_parts, accent_parts, h)
		CharacterDefinition.Category.WINGED:
			_build_winged(body_parts, accent_parts, h)
		CharacterDefinition.Category.SERPENTINE:
			_build_serpentine(body_parts, accent_parts, h)
		_:
			_build_custom(body_parts, accent_parts, h)
	var mesh := MeshBuilder.build_surface_groups(groups, detail, materials)
	var visual := MeshInstance3D.new()
	visual.name = "ProceduralCreaturePreviewMesh"
	visual.mesh = mesh
	var root := Node3D.new()
	root.name = String(definition.character_id).validate_node_name()
	root.set_meta("generator_quality", "procedural_creature_preview")
	root.set_meta("generation_seed", definition.generation_seed)
	root.set_meta("species", definition.species)
	root.add_child(visual)
	visual.owner = root
	return root


static func _build_quadruped(body: Array, accents: Array, h: float) -> void:
	_add(body, Vector3(0, h * 0.57, 0), Vector3(h * 0.23, h * 0.21, h * 0.43), Vector3.FORWARD)
	_add(
		body, Vector3(0, h * 0.66, h * 0.34), Vector3(h * 0.13, h * 0.13, h * 0.22), Vector3.FORWARD
	)
	_add(
		body, Vector3(0, h * 0.74, h * 0.52), Vector3(h * 0.15, h * 0.13, h * 0.19), Vector3.FORWARD
	)
	_add(
		accents,
		Vector3(0, h * 0.70, h * 0.68),
		Vector3(h * 0.05, h * 0.06, h * 0.13),
		Vector3.FORWARD
	)  # muzzle
	for side in [-1.0, 1.0]:
		for zpos in [-0.27, 0.29]:
			_add(
				body,
				Vector3(side * h * 0.15, h * 0.35, zpos * h),
				Vector3(h * 0.075, h * 0.23, h * 0.085),
				Vector3.UP
			)
			_add(
				body,
				Vector3(side * h * 0.15, h * 0.10, zpos * h),
				Vector3(h * 0.06, h * 0.14, h * 0.065),
				Vector3.UP
			)
	_add(
		body, Vector3(0, h * 0.59, -h * 0.48), Vector3(h * 0.065, h * 0.07, h * 0.28), Vector3.BACK
	)


static func _build_winged(body: Array, accents: Array, h: float) -> void:
	_add(body, Vector3(0, h * 0.52, 0), Vector3(h * 0.19, h * 0.25, h * 0.24), Vector3.FORWARD)
	_add(
		body, Vector3(0, h * 0.74, h * 0.20), Vector3(h * 0.14, h * 0.15, h * 0.19), Vector3.FORWARD
	)
	_add(
		body,
		Vector3(0, h * 0.80, h * 0.37),
		Vector3(h * 0.105, h * 0.10, h * 0.14),
		Vector3.FORWARD
	)
	_add(
		accents,
		Vector3(0, h * 0.77, h * 0.51),
		Vector3(h * 0.045, h * 0.05, h * 0.13),
		Vector3.FORWARD
	)
	for side in [-1.0, 1.0]:
		_add(
			body,
			Vector3(side * h * 0.30, h * 0.57, 0),
			Vector3(h * 0.12, h * 0.09, h * 0.27),
			Vector3(side, 0.7, 0.3)
		)
		_add(
			body,
			Vector3(side * h * 0.56, h * 0.45, h * 0.02),
			Vector3(h * 0.12, h * 0.065, h * 0.29),
			Vector3(side, -0.4, 0.2)
		)
		_add(
			body,
			Vector3(side * h * 0.14, h * 0.29, -h * 0.09),
			Vector3(h * 0.075, h * 0.19, h * 0.08),
			Vector3.UP
		)
	_add(
		body, Vector3(0, h * 0.51, -h * 0.39), Vector3(h * 0.055, h * 0.06, h * 0.28), Vector3.BACK
	)


static func _build_serpentine(body: Array, accents: Array, h: float) -> void:
	for segment in range(7):
		var t := float(segment) / 6.0
		var z := lerpf(h * 0.34, -h * 0.55, t)
		var y := h * (0.70 - 0.10 * sin(t * PI))
		var radius := lerpf(h * 0.14, h * 0.045, t)
		_add(body, Vector3(0, y, z), Vector3(radius, radius, h * 0.17), Vector3.FORWARD)
	_add(
		body, Vector3(0, h * 0.72, h * 0.49), Vector3(h * 0.16, h * 0.13, h * 0.18), Vector3.FORWARD
	)
	_add(
		accents,
		Vector3(0, h * 0.68, h * 0.64),
		Vector3(h * 0.075, h * 0.055, h * 0.12),
		Vector3.FORWARD
	)


static func _build_custom(body: Array, accents: Array, h: float) -> void:
	# Deliberate fallback body profile; custom attachment-point authoring is a later phase.
	_add(body, Vector3(0, h * 0.52, 0), Vector3(h * 0.22, h * 0.25, h * 0.16))
	_add(body, Vector3(0, h * 0.82, 0), Vector3(h * 0.15, h * 0.17, h * 0.14))
	for side in [-1.0, 1.0]:
		_add(body, Vector3(side * h * 0.19, h * 0.30, 0), Vector3(h * 0.08, h * 0.25, h * 0.09))
	_add(
		accents,
		Vector3(0, h * 0.81, h * 0.12),
		Vector3(h * 0.04, h * 0.04, h * 0.12),
		Vector3.FORWARD
	)


static func _add(parts: Array, center: Vector3, radii: Vector3, axis: Vector3 = Vector3.UP) -> void:
	parts.append({"center": center, "radii": radii, "axis": axis})
