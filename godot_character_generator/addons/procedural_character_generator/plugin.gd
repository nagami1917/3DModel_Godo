@tool
extends EditorPlugin

const DockScript = preload("res://addons/procedural_character_generator/generator_dock.gd")
var dock: Control


func _enter_tree() -> void:
	dock = DockScript.new()
	dock.name = "CharacterGeneratorDock"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree() -> void:
	if is_instance_valid(dock):
		remove_control_from_docks(dock)
		dock.queue_free()
	dock = null
