extends SceneTree

const DefinitionScript = preload("res://scripts/data/character_definition.gd")
const Generator = preload("res://scripts/generation/character_generator.gd")
const Assembler = preload("res://scripts/generation/scene_assembler.gd")
const Validator = preload("res://scripts/validation/asset_validator.gd")


func _initialize() -> void:
	var definition: CharacterDefinition = DefinitionScript.new()
	definition.character_id = &"smoke_humanoid"
	definition.generation_seed = 345
	definition.geometry_detail = 12
	var humanoid := Generator.generate(definition)
	if humanoid == null:
		_fail("Humanoid generation returned null.")
		return
	var mesh_node := humanoid.find_child("ProceduralPreviewMesh", true, false) as MeshInstance3D
	if mesh_node == null or mesh_node.mesh == null or mesh_node.mesh.get_surface_count() == 0:
		_fail("Humanoid generation produced no mesh surfaces.")
		return
	var first_vertices: PackedVector3Array = mesh_node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var repeated := Generator.generate(definition)
	var repeated_mesh := repeated.find_child("ProceduralPreviewMesh", true, false) as MeshInstance3D
	var repeated_vertices: PackedVector3Array = repeated_mesh.mesh.surface_get_arrays(0)[
		Mesh.ARRAY_VERTEX
	]
	if first_vertices != repeated_vertices:
		_fail("Identical definitions and seeds did not reproduce identical vertex data.")
		return
	var actor := Assembler.make_actor(humanoid, definition)
	var report := Validator.validate(actor, true)
	if not report["passed"]:
		_fail(Validator.format_report(report))
		return
	definition.category = CharacterDefinition.Category.QUADRUPED
	var creature := Generator.generate(definition)
	if (
		creature == null
		or creature.find_child("ProceduralCreaturePreviewMesh", true, false) == null
	):
		_fail("Quadruped creature preview generation failed.")
		return
	print("Procedural character smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
