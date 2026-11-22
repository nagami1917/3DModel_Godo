class_name CharacterMaterialLibrary
extends RefCounted


## Shared lightweight PBR presets. Materials are created per character and reused
## across that character's mesh surfaces to keep resource ownership predictable.
static func create_skin(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "Skin"
	material.albedo_color = color
	material.roughness = 0.78
	material.metallic = 0.0
	return material


static func create_cloth(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "Woven cloth"
	material.albedo_color = color
	material.roughness = 0.92
	material.metallic = 0.0
	return material


static func create_organic(color: Color, roughness_value: float = 0.86) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "Creature surface"
	material.albedo_color = color
	material.roughness = roughness_value
	return material
