@tool
class_name CharacterDefinition
extends Resource

## Serializable, deterministic input to the procedural asset pipeline.
enum Category { HUMANOID, QUADRUPED, WINGED, SERPENTINE, CUSTOM }
enum Quality { PREVIEW, STANDARD, HIGH, CINEMATIC }

@export var character_id: StringName = &"wanderer"
@export var display_name: String = "Wanderer"
@export var category: Category = Category.HUMANOID
@export var species: String = "human"
@export var body_type: String = "athletic"
@export_range(0.3, 4.0, 0.01, "suffix:m") var height_m: float = 1.8
@export_range(0.2, 2.0, 0.01) var shoulder_width: float = 0.43
@export_range(0.15, 2.0, 0.01) var hip_width: float = 0.32
@export_range(0.05, 0.5, 0.01) var head_height_ratio: float = 0.135
@export_range(0.5, 1.5, 0.01) var body_mass: float = 1.0
@export var skin_color: Color = Color(0.62, 0.39, 0.28)
@export var secondary_color: Color = Color(0.20, 0.15, 0.12)
@export var accent_color: Color = Color(0.48, 0.12, 0.09)
@export var quality: Quality = Quality.STANDARD
@export var geometry_detail: int = 20
@export var generation_seed: int = 1917
@export var generate_collision: bool = true
@export_range(0.1, 2.5, 0.01, "suffix:m") var collision_height_m: float = 1.75
@export_range(0.05, 1.0, 0.01, "suffix:m") var collision_radius_m: float = 0.28
@export var output_directory: String = "res://generated/characters"


func normalized_height() -> float:
	return clampf(height_m, 0.3, 4.0)


func normalized_detail() -> int:
	return clampi(geometry_detail, 8, 64)


func get_seeded_rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed
	return rng
