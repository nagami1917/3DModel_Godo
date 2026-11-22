extends Node3D

## Turntable demo for the generated voxel tanks.
##
## The GLBs carry a static idle mesh: a hull node and (when the sculpt has one)
## a separately pivoted "Turret" node. Nothing here animates tracks — that is
## gameplay, not an asset. It only proves the model imports, sits on y = 0 and
## that the turret can be yawed by rotating a node.

const TURRET_NODE := "Turret"
const TURNTABLE_DEGREES_PER_SECOND := 12.0
const TURRET_YAW_DEGREES := 18.0

@onready var camera: Camera3D = $Camera3D
@onready var turntables: Array[Node3D] = [$Standard, $Allies]

var _turret_offsets: Array[float] = []

func _ready() -> void:
	_place_camera()
	for i in turntables.size():
		_turret_offsets.append(0.0)
		if _find_turret(turntables[i]) == null:
			print("%s: no turret node (single rigid body), hull only" % turntables[i].name)

func _place_camera() -> void:
	if camera == null:
		return
	camera.look_at_from_position(Vector3(4.2, 2.4, 5.2), Vector3(0.0, 0.45, 0.0), Vector3.UP)

func _find_turret(root: Node) -> Node3D:
	for child in root.get_children():
		if child is Node3D and child.name == TURRET_NODE:
			return child as Node3D
		var found := _find_turret(child)
		if found != null:
			return found
	return null

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(TURNTABLE_DEGREES_PER_SECOND * delta))
	for i in turntables.size():
		# Sweep each turret a little out of phase so the pivot is visible.
		_turret_offsets[i] = fmod(_turret_offsets[i] + delta * 14.0, 360.0)
		var turret := _find_turret(turntables[i])
		if turret != null:
			turret.rotation_degrees.y = sin(deg_to_rad(_turret_offsets[i])) * TURRET_YAW_DEGREES
