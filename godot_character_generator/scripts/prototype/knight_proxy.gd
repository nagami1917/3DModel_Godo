extends Node3D

## Small, original, unrigged armor proxy for Stage 1. Replace this node's visual
## hierarchy with a skinned GLB later; the controller/physics capsule are separate.
var _steel: StandardMaterial3D
var _dark_steel: StandardMaterial3D
var _mail: StandardMaterial3D
var _brass: StandardMaterial3D
var _crimson: StandardMaterial3D
var _leather: StandardMaterial3D
var _undersuit: StandardMaterial3D


func _ready() -> void:
	_create_materials()
	_build_knight()


func _create_materials() -> void:
	_steel = _make_material(Color("#66727a"), 0.72, 0.38)
	_dark_steel = _make_material(Color("#303b43"), 0.68, 0.43)
	_mail = _make_material(Color("#596168"), 0.58, 0.58)
	_brass = _make_material(Color("#bd9145"), 0.74, 0.34)
	_crimson = _make_material(Color("#741e29"), 0.08, 0.72)
	_leather = _make_material(Color("#39291f"), 0.0, 0.84)
	_undersuit = _make_material(Color("#20252b"), 0.12, 0.9)


func _build_knight() -> void:
	_build_torso()
	_build_head()
	_build_leg("LeftLegPivot", -1.0)
	_build_leg("RightLegPivot", 1.0)
	_build_arm("LeftArmPivot", -1.0, true)
	_build_arm("RightArmPivot", 1.0, false)


func _build_torso() -> void:
	var torso := _pivot("TorsoPivot", self, Vector3(0.0, 1.12, 0.0))
	_add_capsule(torso, "ChainmailBody", 0.22, 0.58, Vector3(0.0, 0.02, 0.0), _mail)
	_add_sphere(torso, "Cuirass", Vector3(0.0, 0.07, -0.105), Vector3(0.255, 0.285, 0.13), _steel)
	_add_box(
		torso,
		"BreastplateRidge",
		Vector3(0.055, 0.28, 0.035),
		Vector3(0.0, 0.08, -0.23),
		_dark_steel
	)
	_add_box(
		torso, "LowerCuirass", Vector3(0.39, 0.19, 0.08), Vector3(0.0, -0.17, -0.15), _dark_steel
	)
	_add_box(torso, "Belt", Vector3(0.44, 0.075, 0.30), Vector3(0.0, -0.16, 0.0), _leather)
	_add_box(
		torso, "BuckleFrame", Vector3(0.105, 0.085, 0.035), Vector3(0.0, -0.16, -0.168), _brass
	)
	_add_box(
		torso, "BuckleInset", Vector3(0.052, 0.042, 0.012), Vector3(0.0, -0.16, -0.189), _leather
	)
	_add_box(torso, "Tabard", Vector3(0.19, 0.37, 0.045), Vector3(0.0, -0.39, -0.145), _crimson)
	_add_box(torso, "TabardTrim", Vector3(0.035, 0.34, 0.012), Vector3(0.0, -0.39, -0.173), _brass)
	for side in [-1.0, 1.0]:
		_add_sphere(
			torso,
			"Pauldron_%s" % side,
			Vector3(side * 0.285, 0.24, 0.0),
			Vector3(0.155, 0.13, 0.16),
			_dark_steel
		)
		_add_box(
			torso,
			"Tasset_%s" % side,
			Vector3(0.16, 0.22, 0.07),
			Vector3(side * 0.16, -0.31, -0.10),
			_steel
		)
		_add_sphere(
			torso,
			"PauldronRivet_%s" % side,
			Vector3(side * 0.29, 0.25, -0.151),
			Vector3(0.027, 0.027, 0.018),
			_brass
		)
	_add_sphere(
		torso, "ChestSigil", Vector3(0.0, 0.13, -0.238), Vector3(0.045, 0.055, 0.018), _brass
	)


func _build_head() -> void:
	var head := _pivot("HeadPivot", self, Vector3(0.0, 1.56, 0.0))
	_add_capsule(head, "NeckMail", 0.09, 0.19, Vector3(0.0, -0.08, 0.0), _mail)
	_add_sphere(
		head, "FaceShadow", Vector3(0.0, 0.025, -0.045), Vector3(0.105, 0.135, 0.095), _undersuit
	)
	_add_sphere(head, "HelmetDome", Vector3(0.0, 0.105, 0.0), Vector3(0.15, 0.15, 0.14), _steel)
	_add_box(
		head, "HelmetBrow", Vector3(0.28, 0.065, 0.075), Vector3(0.0, 0.045, -0.127), _dark_steel
	)
	_add_box(head, "EyeSlit", Vector3(0.115, 0.018, 0.018), Vector3(0.0, 0.012, -0.17), _undersuit)
	_add_box(head, "NasalGuard", Vector3(0.035, 0.14, 0.035), Vector3(0.0, -0.07, -0.167), _steel)
	for side in [-1.0, 1.0]:
		_add_box(
			head,
			"CheekGuard_%s" % side,
			Vector3(0.07, 0.18, 0.08),
			Vector3(side * 0.105, -0.07, -0.075),
			_dark_steel
		)
	_add_capsule(head, "CrimsonPlume", 0.026, 0.24, Vector3(0.0, 0.285, 0.015), _crimson)
	_add_sphere(
		head, "PlumeRivet", Vector3(0.0, 0.18, -0.125), Vector3(0.028, 0.028, 0.018), _brass
	)


func _build_leg(pivot_name: String, side: float) -> void:
	var hip := _pivot(pivot_name, self, Vector3(side * 0.135, 0.86, 0.0))
	_add_capsule(hip, "UpperLeg", 0.105, 0.46, Vector3(0.0, -0.21, 0.0), _undersuit)
	_add_box(hip, "ThighPlate", Vector3(0.16, 0.26, 0.065), Vector3(0.0, -0.18, -0.09), _dark_steel)
	var knee := _pivot("KneePivot", hip, Vector3(0.0, -0.42, 0.0))
	_add_sphere(knee, "KneeCop", Vector3(0.0, -0.015, -0.025), Vector3(0.105, 0.10, 0.09), _steel)
	_add_sphere(
		knee, "KneeRivet", Vector3(0.0, -0.015, -0.113), Vector3(0.018, 0.018, 0.01), _brass
	)
	_add_capsule(knee, "LowerLeg", 0.078, 0.43, Vector3(0.0, -0.20, 0.0), _undersuit)
	_add_box(knee, "Greave", Vector3(0.145, 0.31, 0.07), Vector3(0.0, -0.20, -0.073), _steel)
	_add_box(knee, "GreaveRidge", Vector3(0.024, 0.25, 0.018), Vector3(0.0, -0.20, -0.116), _brass)
	_add_box(knee, "Boot", Vector3(0.20, 0.17, 0.34), Vector3(0.0, -0.35, -0.065), _leather)
	_add_box(
		knee, "BootToeCap", Vector3(0.17, 0.065, 0.13), Vector3(0.0, -0.31, -0.16), _dark_steel
	)


func _build_arm(pivot_name: String, side: float, has_shield: bool) -> void:
	var shoulder := _pivot(pivot_name, self, Vector3(side * 0.30, 1.37, 0.0))
	_add_sphere(shoulder, "ShoulderJoint", Vector3.ZERO, Vector3(0.11, 0.115, 0.11), _mail)
	_add_capsule(shoulder, "UpperArm", 0.082, 0.40, Vector3(0.0, -0.19, 0.0), _undersuit)
	_add_box(
		shoulder,
		"UpperArmPlate",
		Vector3(0.15, 0.23, 0.06),
		Vector3(0.0, -0.16, -0.075),
		_dark_steel
	)
	var elbow := _pivot("ElbowPivot", shoulder, Vector3(0.0, -0.37, 0.0))
	_add_sphere(elbow, "ElbowCop", Vector3.ZERO, Vector3(0.085, 0.08, 0.08), _steel)
	_add_capsule(elbow, "Forearm", 0.069, 0.36, Vector3(0.0, -0.17, 0.0), _undersuit)
	_add_box(elbow, "Vambrace", Vector3(0.13, 0.24, 0.07), Vector3(0.0, -0.17, -0.07), _steel)
	_add_box(
		elbow, "VambraceRidge", Vector3(0.022, 0.21, 0.018), Vector3(0.0, -0.17, -0.112), _brass
	)
	var hand := _pivot("HandPivot", elbow, Vector3(0.0, -0.35, 0.0))
	_add_box(hand, "Gauntlet", Vector3(0.11, 0.12, 0.10), Vector3(0.0, -0.04, -0.02), _dark_steel)
	_add_sphere(
		hand, "GauntletBoss", Vector3(0.0, -0.04, -0.074), Vector3(0.035, 0.035, 0.012), _brass
	)
	if has_shield:
		_build_shield(hand)
	else:
		_build_sword(hand)


func _build_shield(parent: Node3D) -> void:
	_add_box(
		parent, "KiteShield", Vector3(0.31, 0.43, 0.075), Vector3(-0.09, -0.12, -0.105), _crimson
	)
	_add_box(
		parent, "ShieldRimTop", Vector3(0.31, 0.035, 0.09), Vector3(-0.09, 0.095, -0.112), _brass
	)
	_add_box(
		parent,
		"ShieldRimBottom",
		Vector3(0.23, 0.028, 0.08),
		Vector3(-0.09, -0.335, -0.112),
		_brass
	)
	_add_box(
		parent, "ShieldRimLeft", Vector3(0.028, 0.38, 0.08), Vector3(-0.232, -0.12, -0.112), _brass
	)
	_add_box(
		parent, "ShieldRimRight", Vector3(0.028, 0.38, 0.08), Vector3(0.052, -0.12, -0.112), _brass
	)
	_add_sphere(
		parent, "ShieldBoss", Vector3(-0.09, -0.12, -0.17), Vector3(0.065, 0.065, 0.035), _steel
	)
	_add_box(
		parent,
		"ShieldCrossVertical",
		Vector3(0.035, 0.22, 0.025),
		Vector3(-0.09, -0.12, -0.202),
		_brass
	)
	_add_box(
		parent,
		"ShieldCrossHorizontal",
		Vector3(0.14, 0.035, 0.025),
		Vector3(-0.09, -0.12, -0.202),
		_brass
	)


func _build_sword(parent: Node3D) -> void:
	var sword := _pivot("SwordPivot", parent, Vector3(0.02, -0.02, -0.03))
	_add_box(sword, "Grip", Vector3(0.055, 0.18, 0.055), Vector3(0.0, 0.055, 0.0), _leather)
	_add_box(sword, "Pommel", Vector3(0.075, 0.055, 0.07), Vector3(0.0, 0.16, 0.0), _brass)
	_add_box(sword, "Crossguard", Vector3(0.22, 0.035, 0.055), Vector3(0.0, -0.045, -0.015), _brass)
	_add_box(sword, "Blade", Vector3(0.075, 0.50, 0.025), Vector3(0.0, -0.31, -0.015), _steel)
	_add_box(sword, "BladePoint", Vector3(0.045, 0.09, 0.024), Vector3(0.0, -0.60, -0.015), _steel)


func _pivot(node_name: String, parent: Node3D, local_position: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = local_position
	parent.add_child(pivot)
	return pivot


func _add_box(
	parent: Node3D, node_name: String, size: Vector3, local_position: Vector3, material: Material
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = local_position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _add_sphere(
	parent: Node3D, node_name: String, local_position: Vector3, radii: Vector3, material: Material
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	instance.mesh = mesh
	instance.position = local_position
	instance.scale = radii
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _add_capsule(
	parent: Node3D,
	node_name: String,
	radius: float,
	height: float,
	local_position: Vector3,
	material: Material
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6
	instance.mesh = mesh
	instance.position = local_position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _make_material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
