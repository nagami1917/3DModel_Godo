class_name CharacterSceneAssembler
extends RefCounted


static func make_actor(visual: Node3D, definition: CharacterDefinition) -> CharacterBody3D:
	if visual == null or definition == null:
		return null
	var actor := CharacterBody3D.new()
	actor.name = String(definition.character_id).validate_node_name() + "Actor"
	actor.collision_layer = 1
	actor.collision_mask = 1
	actor.add_child(visual)
	visual.owner = actor
	if definition.generate_collision:
		var collision := CollisionShape3D.new()
		collision.name = "GameplayCapsule"
		var capsule := CapsuleShape3D.new()
		capsule.height = maxf(definition.collision_height_m, definition.collision_radius_m * 2.0)
		capsule.radius = minf(definition.collision_radius_m, capsule.height * 0.49)
		collision.shape = capsule
		collision.position.y = capsule.height * 0.5
		actor.add_child(collision)
		collision.owner = actor
	return actor


static func assign_owner_recursive(root: Node, owner: Node) -> void:
	for child in root.get_children():
		child.owner = owner
		assign_owner_recursive(child, owner)
