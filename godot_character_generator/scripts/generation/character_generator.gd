class_name ProceduralCharacterGenerator
extends RefCounted

const MeshBuilder = preload("res://scripts/generation/parametric_mesh_builder.gd")
const Materials = preload("res://scripts/generation/material_library.gd")


static func generate(definition: CharacterDefinition) -> Node3D:
	if definition == null:
		push_error("Character generation requires a CharacterDefinition.")
		return null
	var creature_categories := [
		CharacterDefinition.Category.QUADRUPED,
		CharacterDefinition.Category.WINGED,
		CharacterDefinition.Category.SERPENTINE,
		CharacterDefinition.Category.CUSTOM,
	]
	if definition.category in creature_categories:
		return ProceduralCreatureGenerator.generate(definition)
	return _generate_humanoid(definition)


static func _generate_humanoid(definition: CharacterDefinition) -> Node3D:
	var rng := definition.get_seeded_rng()
	var form_variation := rng.randf_range(0.97, 1.03)
	var shoulder_width := definition.shoulder_width * form_variation
	var hip_width := definition.hip_width * rng.randf_range(0.97, 1.03)
	var h := definition.normalized_height()
	var detail := definition.normalized_detail()
	var head_h := h * definition.head_height_ratio
	var head_center := h * 0.93
	var ankle_y := h * 0.035
	var knee_y := h * 0.28
	var hip_y := h * 0.51
	var shoulder_y := h * 0.77
	var elbow_y := h * 0.59
	var wrist_y := h * 0.43
	var skin := Materials.create_skin(definition.skin_color)
	var cloth := Materials.create_cloth(definition.secondary_color)
	var accent := Materials.create_cloth(definition.accent_color)
	var materials: Array[Material] = [skin, cloth, accent]
	var groups: Array[Dictionary] = [{"parts": []}, {"parts": []}, {"parts": []}]
	var skin_parts: Array = groups[0]["parts"]
	var cloth_parts: Array = groups[1]["parts"]
	var accent_parts: Array = groups[2]["parts"]
	# Overlapping shaped volumes create readable anatomical masses, while keeping
	# the output deliberately categorized as a procedural preview/blockout.
	_add(skin_parts, Vector3(0, h * 0.70, 0), Vector3(shoulder_width * 0.48, h * 0.19, h * 0.115))
	_add(skin_parts, Vector3(0, h * 0.55, 0), Vector3(hip_width * 0.42, h * 0.105, h * 0.09))  # waist
	_add(skin_parts, Vector3(0, hip_y, 0), Vector3(hip_width * 0.55, h * 0.085, h * 0.105))  # pelvis
	_add(skin_parts, Vector3(0, h * 0.79, 0), Vector3(shoulder_width * 0.53, h * 0.085, h * 0.105))
	_add(
		skin_parts,
		Vector3(0, h * 0.82, 0),
		Vector3(shoulder_width * 0.16, h * 0.075, h * 0.13),
		Vector3.UP
	)  # upper chest
	_add(
		skin_parts,
		Vector3(0, head_center - head_h * 0.78, 0),
		Vector3(h * 0.065, h * 0.10, h * 0.07)
	)  # neck
	_add(
		skin_parts, Vector3(0, head_center, 0), Vector3(head_h * 0.42, head_h * 0.50, head_h * 0.38)
	)  # skull
	_add(
		skin_parts,
		Vector3(0, head_center - head_h * 0.25, h * 0.025),
		Vector3(head_h * 0.29, head_h * 0.24, head_h * 0.29)
	)  # jaw
	_add(
		skin_parts,
		Vector3(0, head_center - head_h * 0.12, h * 0.075),
		Vector3(head_h * 0.085, head_h * 0.16, head_h * 0.10)
	)  # nose bridge
	for side in [-1.0, 1.0]:
		_add(
			skin_parts,
			Vector3(side * head_h * 0.41, head_center, 0),
			Vector3(head_h * 0.10, head_h * 0.17, head_h * 0.08)
		)  # ears
		var shoulder := Vector3(side * shoulder_width * 0.48, shoulder_y, 0)
		_add(skin_parts, shoulder, Vector3(h * 0.075, h * 0.085, h * 0.085))
		_add(
			skin_parts,
			Vector3(side * shoulder_width * 0.51, (shoulder_y + elbow_y) * 0.5, 0),
			Vector3(h * 0.065, h * 0.12, h * 0.065),
			Vector3(0, 1, 0.04)
		)
		_add(
			skin_parts,
			Vector3(side * shoulder_width * 0.53, elbow_y, 0),
			Vector3(h * 0.052, h * 0.055, h * 0.055)
		)
		_add(
			skin_parts,
			Vector3(side * shoulder_width * 0.55, (elbow_y + wrist_y) * 0.5, 0),
			Vector3(h * 0.052, h * 0.105, h * 0.052),
			Vector3(0, 1, 0.03)
		)
		_add(
			skin_parts,
			Vector3(side * shoulder_width * 0.55, wrist_y, 0),
			Vector3(h * 0.04, h * 0.045, h * 0.04)
		)
		_add(
			skin_parts,
			Vector3(side * shoulder_width * 0.56, wrist_y - h * 0.045, h * 0.015),
			Vector3(h * 0.055, h * 0.065, h * 0.035)
		)  # palm
		_add(
			skin_parts,
			Vector3(side * shoulder_width * 0.57, wrist_y - h * 0.105, h * 0.02),
			Vector3(h * 0.012, h * 0.045, h * 0.012)
		)  # fingers mass
		_add(
			skin_parts,
			Vector3(side * hip_width * 0.28, (hip_y + knee_y) * 0.5, 0),
			Vector3(h * 0.095, h * 0.16, h * 0.095)
		)  # thigh
		_add(
			skin_parts,
			Vector3(side * hip_width * 0.28, knee_y, h * 0.005),
			Vector3(h * 0.067, h * 0.075, h * 0.07)
		)  # knee
		_add(
			skin_parts,
			Vector3(side * hip_width * 0.28, (knee_y + ankle_y) * 0.5, -h * 0.005),
			Vector3(h * 0.067, h * 0.15, h * 0.07)
		)  # calf
		_add(
			skin_parts,
			Vector3(side * hip_width * 0.28, ankle_y, h * 0.045),
			Vector3(h * 0.06, h * 0.04, h * 0.11)
		)  # foot
	# Simple tunic and belt are distinct reusable material groups.
	_add(
		cloth_parts,
		Vector3(0, h * 0.67, -h * 0.005),
		Vector3(shoulder_width * 0.39, h * 0.15, h * 0.12)
	)
	_add(
		accent_parts,
		Vector3(0, h * 0.54, h * 0.005),
		Vector3(hip_width * 0.48, h * 0.025, h * 0.115)
	)
	var mesh := MeshBuilder.build_surface_groups(groups, detail, materials)
	var visual := MeshInstance3D.new()
	visual.name = "ProceduralPreviewMesh"
	visual.mesh = mesh
	var root := Node3D.new()
	root.name = String(definition.character_id).validate_node_name()
	root.set_meta("generator_quality", "procedural_preview")
	root.set_meta("generation_seed", definition.generation_seed)
	root.set_meta("species", definition.species)
	root.add_child(visual)
	visual.owner = root
	return root


static func _add(parts: Array, center: Vector3, radii: Vector3, axis: Vector3 = Vector3.UP) -> void:
	parts.append({"center": center, "radii": radii, "axis": axis})
