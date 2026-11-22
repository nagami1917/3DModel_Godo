class_name ParametricMeshBuilder
extends RefCounted


## Builds smooth, UV-mapped ellipsoidal anatomical volumes into material-grouped
## ArrayMesh surfaces. This is a blockout-quality procedural surface primitive,
## not a replacement for authored deformation-ready anatomy.
static func build_surface_groups(
	groups: Array[Dictionary], detail: int, materials: Array[Material]
) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var segments := clampi(detail, 8, 64)
	for group_index in range(groups.size()):
		var tool := SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		for part in groups[group_index].get("parts", []):
			_append_ellipsoid(
				tool,
				part.get("center", Vector3.ZERO),
				part.get("radii", Vector3.ONE),
				part.get("axis", Vector3.UP),
				segments
			)
		if tool.get_vertex_count() == 0:
			continue
		tool.generate_normals()
		var surface_index := mesh.get_surface_count()
		tool.commit(mesh)
		if group_index < materials.size():
			mesh.surface_set_material(surface_index, materials[group_index])
	return mesh


static func _append_ellipsoid(
	tool: SurfaceTool, center: Vector3, radii: Vector3, axis: Vector3, segments: int
) -> void:
	var y_axis := axis.normalized()
	if y_axis.length_squared() < 0.5:
		y_axis = Vector3.UP
	var x_axis := Vector3.FORWARD.cross(y_axis).normalized()
	if x_axis.length_squared() < 0.01:
		x_axis = Vector3.RIGHT.cross(y_axis).normalized()
	var z_axis := x_axis.cross(y_axis).normalized()
	var orient := Basis(x_axis, y_axis, z_axis)
	var latitude_steps := maxi(segments / 2, 4)
	var longitude_steps := segments
	var base_index := tool.get_vertex_count()
	for latitude in range(latitude_steps + 1):
		var lat := -PI * 0.5 + PI * float(latitude) / float(latitude_steps)
		for longitude in range(longitude_steps + 1):
			var lon := TAU * float(longitude) / float(longitude_steps)
			tool.set_uv(
				Vector2(float(longitude) / longitude_steps, float(latitude) / latitude_steps)
			)
			tool.add_vertex(_vertex(center, radii, orient, lat, lon))
	for latitude in range(latitude_steps):
		for longitude in range(longitude_steps):
			var a := base_index + latitude * (longitude_steps + 1) + longitude
			var b := a + longitude_steps + 1
			var c := a + 1
			var d := b + 1
			# Indexed vertices let SurfaceTool average normals across each ellipsoid.
			# Pole fans use one triangle per sector to avoid zero-area faces.
			if latitude == 0:
				tool.add_index(a)
				tool.add_index(b)
				tool.add_index(d)
			elif latitude == latitude_steps - 1:
				tool.add_index(a)
				tool.add_index(b)
				tool.add_index(c)
			else:
				tool.add_index(a)
				tool.add_index(b)
				tool.add_index(c)
				tool.add_index(b)
				tool.add_index(d)
				tool.add_index(c)


static func _vertex(
	center: Vector3, radii: Vector3, orient: Basis, latitude: float, longitude: float
) -> Vector3:
	var radial := Vector3(
		cos(latitude) * cos(longitude), sin(latitude), cos(latitude) * sin(longitude)
	)
	return center + orient * (radial * radii)
