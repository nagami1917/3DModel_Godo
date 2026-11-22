extends Node3D

## Camera is a sibling of the player so its yaw is independent of player turning.
@export_category("Target")
@export var target_path: NodePath = ^"../KnightPlayer"

@export_category("Camera")
@export_range(0.0005, 0.01, 0.0001) var mouse_sensitivity: float = 0.0022
@export_range(0.0, 30.0, 0.1) var follow_response: float = 18.0
@export_range(-80.0, 0.0, 0.1) var min_pitch_degrees: float = -38.0
@export_range(0.0, 80.0, 0.1) var max_pitch_degrees: float = 24.0
@export_range(0.0, 0.5, 0.01) var shoulder_height: float = 1.42
@export_range(-1.0, 1.0, 0.01) var shoulder_offset: float = 0.42

var target: Node3D
var yaw: float = 0.0
var pitch: float = deg_to_rad(-8.0)

@onready var spring_arm: SpringArm3D = $SpringArm3D


func _ready() -> void:
	target = get_node_or_null(target_path) as Node3D
	if target == null:
		push_error("ThirdPersonCameraRig: target was not found at %s." % target_path)
	else:
		global_position = _desired_follow_position()
		if target is CollisionObject3D:
			spring_arm.add_excluded_object((target as CollisionObject3D).get_rid())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_update_camera_rotation()


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var weight := 1.0 - exp(-follow_response * delta)
	global_position = global_position.lerp(_desired_follow_position(), weight)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if (
		event is InputEventMouseButton
		and event.pressed
		and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
	):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clampf(
			pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)
		_update_camera_rotation()


func _desired_follow_position() -> Vector3:
	var camera_right := Vector3(cos(yaw), 0.0, -sin(yaw))
	return target.global_position + camera_right * shoulder_offset + Vector3.UP * shoulder_height


func _update_camera_rotation() -> void:
	rotation = Vector3(pitch, yaw, 0.0)
