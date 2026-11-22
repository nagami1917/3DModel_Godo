@tool
extends VBoxContainer

const DefinitionScript = preload("res://scripts/data/character_definition.gd")
const Generator = preload("res://scripts/generation/character_generator.gd")
const Assembler = preload("res://scripts/generation/scene_assembler.gd")
const Validator = preload("res://scripts/validation/asset_validator.gd")

var name_edit: LineEdit
var category_option: OptionButton
var height_spin: SpinBox
var seed_spin: SpinBox
var detail_spin: SpinBox
var output_edit: LineEdit
var preview_viewport: SubViewport
var preview_root: Node3D
var report_label: RichTextLabel


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	custom_minimum_size = Vector2(330, 440)
	var title := Label.new()
	title.text = "Procedural Character Generator"
	title.add_theme_font_size_override("font_size", 16)
	add_child(title)
	var help := Label.new()
	help.text = "Deterministic preview pipeline · Godot 4"
	add_child(help)
	name_edit = _add_line("Character name", "wanderer")
	category_option = OptionButton.new()
	for category in ["Humanoid", "Quadruped", "Winged", "Serpentine", "Custom"]:
		category_option.add_item(category)
	category_option.select(0)
	_add_labeled("Category", category_option)
	height_spin = _add_spin("Height (m)", 1.8, 0.3, 4.0, 0.05)
	seed_spin = _add_spin("Generation seed", 1917, 0, 2147483647, 1)
	detail_spin = _add_spin("Mesh detail", 20, 8, 64, 1)
	output_edit = _add_line("Output folder", "res://generated/characters")
	var actions := HBoxContainer.new()
	add_child(actions)
	for action_name in ["Preview", "Validate", "Save actor"]:
		var button := Button.new()
		button.text = action_name
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_action.bind(action_name))
		actions.add_child(button)
	var preview_label := Label.new()
	preview_label.text = "Preview"
	add_child(preview_label)
	var viewport_container := SubViewportContainer.new()
	viewport_container.custom_minimum_size = Vector2(0, 210)
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container.stretch = true
	add_child(viewport_container)
	preview_viewport = SubViewport.new()
	preview_viewport.size = Vector2i(600, 400)
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(preview_viewport)
	_setup_preview_world()
	report_label = RichTextLabel.new()
	report_label.custom_minimum_size = Vector2(0, 96)
	report_label.fit_content = true
	add_child(report_label)


func _setup_preview_world() -> void:
	var world := Node3D.new()
	world.name = "PreviewWorld"
	preview_viewport.add_child(world)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.current = true
	camera.position = Vector3(0, 1.05, 4.5)
	camera.look_at(Vector3(0, 0.9, 0), Vector3.UP)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -25, 0)
	world.add_child(light)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-2, 1.8, 2)
	fill.light_energy = 0.6
	world.add_child(fill)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(8, 8)
	floor.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.12, 0.13, 0.15)
	floor_material.roughness = 1.0
	floor.material_override = floor_material
	world.add_child(floor)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.065, 0.08)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.65, 0.68, 0.75)
	env.ambient_light_energy = 0.7
	environment.environment = env
	world.add_child(environment)


func _on_action(action_name: String) -> void:
	var definition := _make_definition()
	var visual := Generator.generate(definition)
	if visual == null:
		report_label.text = "Generation failed; check the Godot Output panel."
		return
	match action_name:
		"Preview":
			_show_preview(visual)
			report_label.text = (
				("Preview generated from seed %d.\n" % definition.generation_seed)
				+ "Procedural blockout only; not a finished realistic/rigged asset."
			)
		"Validate":
			_show_preview(visual)
			var result := Validator.validate(visual, false)
			report_label.text = Validator.format_report(result)
		"Save actor":
			_save_actor(visual, definition)


func _show_preview(visual: Node3D) -> void:
	var world := preview_viewport.get_child(0)
	if is_instance_valid(preview_root):
		world.remove_child(preview_root)
		preview_root.queue_free()
	preview_root = visual
	world.add_child(preview_root)


func _save_actor(visual: Node3D, definition: CharacterDefinition) -> void:
	var failure := ""
	var actor: CharacterBody3D
	var packed := PackedScene.new()
	var folder := ""
	var scene_path := ""
	var definition_path := ""
	if not definition.output_directory.begins_with("res://"):
		failure = "Output must be inside this Godot project (use a res:// path)."
	elif String(definition.character_id).strip_edges().is_empty():
		failure = "Enter a non-empty character name/ID before saving."
	else:
		var safe_id := String(definition.character_id).validate_node_name()
		folder = definition.output_directory.simplify_path().path_join(safe_id)
		scene_path = folder.path_join(safe_id + "_actor.tscn")
		definition_path = folder.path_join(safe_id + "_definition.tres")
		var project_root := ProjectSettings.globalize_path("res://").simplify_path()
		var absolute_folder := ProjectSettings.globalize_path(folder).simplify_path()
		if not absolute_folder.begins_with(project_root + "/"):
			failure = "Output path escapes the Godot project directory."
		elif FileAccess.file_exists(scene_path) or FileAccess.file_exists(definition_path):
			failure = "Refusing to overwrite an existing asset; choose a new character ID."
	if failure.is_empty():
		var directory_error := DirAccess.make_dir_recursive_absolute(
			ProjectSettings.globalize_path(folder)
		)
		if directory_error != OK:
			failure = "Could not create output folder (error %d): %s" % [directory_error, folder]
	if failure.is_empty():
		actor = Assembler.make_actor(visual, definition)
		if actor == null:
			failure = "Could not assemble actor scene."
	if failure.is_empty():
		var pack_error := packed.pack(actor)
		if pack_error != OK:
			failure = "Scene packing failed (error %d)." % pack_error
	if actor != null:
		actor.free()
	else:
		visual.queue_free()
	if failure.is_empty():
		var definition_error := ResourceSaver.save(definition, definition_path)
		if definition_error != OK:
			failure = "Definition save failed (error %d)." % definition_error
		else:
			var scene_error := ResourceSaver.save(packed, scene_path)
			if scene_error != OK:
				DirAccess.remove_absolute(ProjectSettings.globalize_path(definition_path))
				failure = (
					"Scene save failed (error %d); the partial definition was removed."
					% scene_error
				)
	if not failure.is_empty():
		report_label.text = failure
		return
	report_label.text = (
		("Saved actor and definition:\n%s\n%s\n\n" % [scene_path, definition_path])
		+ "No rig, animation, textures, or GLB export is included in this phase."
	)


func _make_definition() -> CharacterDefinition:
	var definition := DefinitionScript.new()
	definition.character_id = StringName(name_edit.text.strip_edges().to_lower().replace(" ", "_"))
	definition.display_name = name_edit.text.strip_edges()
	definition.category = category_option.selected
	definition.height_m = height_spin.value
	definition.generation_seed = int(seed_spin.value)
	definition.geometry_detail = int(detail_spin.value)
	definition.output_directory = output_edit.text.strip_edges()
	return definition


func _add_line(label_text: String, initial: String) -> LineEdit:
	var edit := LineEdit.new()
	edit.text = initial
	_add_labeled(label_text, edit)
	return edit


func _add_spin(
	label_text: String, initial: float, minimum: float, maximum: float, step: float
) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = initial
	_add_labeled(label_text, spin)
	return spin


func _add_labeled(label_text: String, control: Control) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 110
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	add_child(row)
