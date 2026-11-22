extends CharacterBody3D

## Stage 1: grounded camera-relative movement and a locomotion-only AnimationTree.
@export_category("Movement")
@export_range(0.5, 8.0, 0.1) var walk_speed: float = 3.2
@export_range(1.0, 10.0, 0.1) var sprint_speed: float = 5.4
@export_range(1.0, 40.0, 0.5) var acceleration: float = 18.0
@export_range(1.0, 50.0, 0.5) var braking: float = 24.0
@export_range(1.0, 24.0, 0.5) var turn_speed: float = 14.0
@export_range(0.0, 1.0, 0.01) var animation_blend_start: float = 0.04

@export_category("References")
@export var camera_rig_path: NodePath = ^"../CameraRig"

var camera_rig: Node3D
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var is_sprinting: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var visual_root: Node3D = $VisualRoot


func _ready() -> void:
	_ensure_stage_one_inputs()
	camera_rig = get_node_or_null(camera_rig_path) as Node3D
	if camera_rig == null:
		push_error("KnightPlayer: CameraRig was not found at %s." % camera_rig_path)
	_build_placeholder_locomotion_animations()
	_build_locomotion_animation_tree()
	floor_snap_length = 0.25
	floor_max_angle = deg_to_rad(48.0)


func _physics_process(delta: float) -> void:
	_update_movement(delta)
	_update_locomotion_blend()


func _update_movement(delta: float) -> void:
	var input_axis := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction := Vector3.ZERO
	if camera_rig != null:
		var camera_forward := -camera_rig.global_basis.z
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()
		var camera_right := camera_rig.global_basis.x
		camera_right.y = 0.0
		camera_right = camera_right.normalized()
		move_direction = camera_right * input_axis.x - camera_forward * input_axis.y
		if move_direction.length_squared() > 1.0:
			move_direction = move_direction.normalized()

	is_sprinting = Input.is_action_pressed("sprint") and input_axis.length_squared() > 0.01
	var desired_speed := sprint_speed if is_sprinting else walk_speed
	var target_horizontal_velocity := move_direction * desired_speed
	var response := acceleration if move_direction.length_squared() > 0.001 else braking
	velocity.x = move_toward(velocity.x, target_horizontal_velocity.x, response * delta)
	velocity.z = move_toward(velocity.z, target_horizontal_velocity.z, response * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	var facing_direction := move_direction
	if facing_direction.length_squared() < 0.01:
		facing_direction = Vector3(velocity.x, 0.0, velocity.z).normalized()
	if facing_direction.length_squared() > 0.01:
		var target_yaw := atan2(-facing_direction.x, -facing_direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))

	move_and_slide()


func _update_locomotion_blend() -> void:
	if animation_tree == null or not animation_tree.active:
		return
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var blend_position := clampf(horizontal_speed / sprint_speed, 0.0, 1.0)
	if horizontal_speed < animation_blend_start:
		blend_position = 0.0
	animation_tree.set("parameters/Locomotion/blend_position", blend_position)


func _build_placeholder_locomotion_animations() -> void:
	var library := AnimationLibrary.new()
	library.add_animation(&"idle", _make_idle_animation())
	library.add_animation(&"walk", _make_cycle_animation("WalkPlaceholder", 0.92, 0.34, 0.012))
	library.add_animation(&"run", _make_cycle_animation("RunPlaceholder", 0.68, 0.68, 0.035))
	var error := animation_player.add_animation_library(&"", library)
	if error != OK:
		push_error("Could not install placeholder locomotion animations (error %d)." % error)


func _make_idle_animation() -> Animation:
	var animation := Animation.new()
	animation.resource_name = "IdlePlaceholder"
	animation.length = 2.4
	animation.loop_mode = Animation.LOOP_LINEAR
	_add_value_track(
		animation,
		"VisualRoot/TorsoPivot:position",
		[
			[0.0, Vector3(0.0, 1.12, 0.0)],
			[1.2, Vector3(0.0, 1.135, 0.0)],
			[2.4, Vector3(0.0, 1.12, 0.0)],
		]
	)
	_add_value_track(
		animation,
		"VisualRoot/HeadPivot:rotation",
		[[0.0, Vector3.ZERO], [0.8, Vector3(0.015, 0.0, 0.0)], [2.4, Vector3.ZERO]]
	)
	return animation


func _make_cycle_animation(
	animation_name: String, duration: float, swing: float, body_bob: float
) -> Animation:
	var animation := Animation.new()
	animation.resource_name = animation_name
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR
	var left_keys := [
		[0.0, Vector3(swing, 0.0, 0.0)],
		[duration * 0.5, Vector3(-swing, 0.0, 0.0)],
		[duration, Vector3(swing, 0.0, 0.0)],
	]
	var right_keys := [
		[0.0, Vector3(-swing, 0.0, 0.0)],
		[duration * 0.5, Vector3(swing, 0.0, 0.0)],
		[duration, Vector3(-swing, 0.0, 0.0)],
	]
	_add_value_track(animation, "VisualRoot/LeftLegPivot:rotation", left_keys)
	_add_value_track(animation, "VisualRoot/RightLegPivot:rotation", right_keys)
	_add_value_track(animation, "VisualRoot/LeftArmPivot:rotation", right_keys)
	_add_value_track(animation, "VisualRoot/RightArmPivot:rotation", left_keys)
	_add_value_track(
		animation,
		"VisualRoot/LeftLegPivot/KneePivot:rotation",
		[
			[0.0, Vector3.ZERO],
			[duration * 0.25, Vector3(-swing * 0.55, 0.0, 0.0)],
			[duration * 0.5, Vector3.ZERO],
			[duration * 0.75, Vector3(-swing * 0.2, 0.0, 0.0)],
			[duration, Vector3.ZERO],
		]
	)
	_add_value_track(
		animation,
		"VisualRoot/RightLegPivot/KneePivot:rotation",
		[
			[0.0, Vector3.ZERO],
			[duration * 0.25, Vector3(-swing * 0.2, 0.0, 0.0)],
			[duration * 0.5, Vector3.ZERO],
			[duration * 0.75, Vector3(-swing * 0.55, 0.0, 0.0)],
			[duration, Vector3.ZERO],
		]
	)
	_add_value_track(
		animation,
		"VisualRoot/TorsoPivot:position",
		[
			[0.0, Vector3(0.0, 1.12 + body_bob, 0.0)],
			[duration * 0.5, Vector3(0.0, 1.12 - body_bob * 0.35, 0.0)],
			[duration, Vector3(0.0, 1.12 + body_bob, 0.0)],
		]
	)
	return animation


func _add_value_track(animation: Animation, path: String, keys: Array) -> void:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, NodePath(path))
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)
	for key_data in keys:
		animation.track_insert_key(track_index, float(key_data[0]), key_data[1])


func _build_locomotion_animation_tree() -> void:
	var blend_space := AnimationNodeBlendSpace1D.new()
	blend_space.min_space = 0.0
	blend_space.max_space = 1.0
	blend_space.snap = 0.01
	var idle_node := AnimationNodeAnimation.new()
	idle_node.animation = "idle"
	blend_space.add_blend_point(idle_node, 0.0)
	var walk_node := AnimationNodeAnimation.new()
	walk_node.animation = "walk"
	blend_space.add_blend_point(walk_node, 0.58)
	var run_node := AnimationNodeAnimation.new()
	run_node.animation = "run"
	blend_space.add_blend_point(run_node, 1.0)

	var blend_tree := AnimationNodeBlendTree.new()
	blend_tree.add_node("Locomotion", blend_space, Vector2(240.0, 120.0))
	blend_tree.connect_node("output", 0, "Locomotion")
	animation_tree.tree_root = blend_tree
	animation_tree.root_node = ^".."
	animation_tree.anim_player = ^"../AnimationPlayer"
	animation_tree.active = true
	animation_tree.set("parameters/Locomotion/blend_position", 0.0)


func _ensure_stage_one_inputs() -> void:
	var bindings := {
		"move_forward": KEY_W,
		"move_back": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"sprint": KEY_SHIFT,
	}
	for action_name in bindings:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name, 0.2)
		var key_event := InputEventKey.new()
		key_event.keycode = int(bindings[action_name])
		key_event.physical_keycode = int(bindings[action_name])
		var already_bound := false
		for existing_event in InputMap.action_get_events(action_name):
			if existing_event is InputEventKey:
				if existing_event.physical_keycode == key_event.physical_keycode:
					already_bound = true
					break
		if not already_bound:
			InputMap.action_add_event(action_name, key_event)
