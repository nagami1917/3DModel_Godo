class_name CharacterAssetValidator
extends RefCounted


## Returns structured, honest diagnostics; this first stage validates scene/mesh
## basics and explicitly warns about missing production rigging and textures.
static func validate(root: Node, require_collision: bool = false) -> Dictionary:
	var report := {
		"passed": true, "critical_errors": [], "warnings": [], "optimizations": [], "checks": []
	}
	if root == null:
		_add(report, "critical_errors", "No generated root node was provided.")
		return report
	var mesh_count := 0
	var surface_count := 0
	var collision_count := 0
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		if node is MeshInstance3D:
			mesh_count += 1
			var mesh_instance := node as MeshInstance3D
			if mesh_instance.mesh == null:
				_add(report, "critical_errors", "%s has no mesh." % node.get_path())
			else:
				var mesh := mesh_instance.mesh
				if mesh.get_surface_count() == 0:
					_add(report, "critical_errors", "%s has an empty mesh." % node.get_path())
				for i in range(mesh.get_surface_count()):
					surface_count += 1
					var arrays := mesh.surface_get_arrays(i)
					if (
						arrays.is_empty()
						or arrays[Mesh.ARRAY_VERTEX] == null
						or arrays[Mesh.ARRAY_VERTEX].is_empty()
					):
						_add(
							report,
							"critical_errors",
							"%s surface %d contains no vertices." % [node.get_path(), i]
						)
					if (
						mesh.surface_get_material(i) == null
						and mesh_instance.material_override == null
					):
						_add(
							report,
							"warnings",
							"%s surface %d has no assigned material." % [node.get_path(), i]
						)
		if node is CollisionShape3D:
			collision_count += 1
	if mesh_count == 0:
		_add(report, "critical_errors", "Generated scene contains no MeshInstance3D nodes.")
	if require_collision and collision_count == 0:
		_add(
			report, "critical_errors", "Collision was requested but no CollisionShape3D was found."
		)
	if root.find_child("Skeleton3D", true, false) == null:
		_add(
			report,
			"warnings",
			"No production skeleton/skin binding is present yet; generated geometry is not animation-ready."
		)
	if mesh_count > 1:
		_add(
			report,
			"optimizations",
			"Consider merging compatible static surfaces to reduce draw calls."
		)
	if mesh_count > 0:
		report["checks"].append(
			"Mesh nodes: %d; material surfaces: %d." % [mesh_count, surface_count]
		)
	_add(
		report,
		"warnings",
		(
			"Procedural preview geometry is not a realistic finished character; "
			+ "use an authored source mesh for production anatomy."
		)
	)
	report["passed"] = report["critical_errors"].is_empty()
	return report


static func format_report(report: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append(
		(
			"Character Asset Validation — %s"
			% ("PASSED (with notes)" if report.get("passed", false) else "FAILED")
		)
	)
	for check in report.get("checks", []):
		lines.append("PASS: %s" % check)
	for error in report.get("critical_errors", []):
		lines.append("ERROR: %s" % error)
	for warning in report.get("warnings", []):
		lines.append("WARNING: %s" % warning)
	for note in report.get("optimizations", []):
		lines.append("OPTIMIZATION: %s" % note)
	return "\n".join(lines)


static func _add(report: Dictionary, bucket: String, message: String) -> void:
	report[bucket].append(message)
