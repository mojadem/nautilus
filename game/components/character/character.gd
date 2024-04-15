@tool
extends CharacterBody3D
class_name Character

@export var physics_enabled := false
@export var mesh: MeshInstance3D

@export_enum("Happy", "Sad", "Angry", "Surprised") var expression: int:
	set(value):
		if not mesh:
			return
		
		expression = value
		var offset: float = float(value) / 4.0
		var material: BaseMaterial3D = mesh.get_surface_override_material(1)
		material.uv1_offset = Vector3(offset, 0, 0)

var anim_tree: AnimationTree
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var moving := false
var speed := 1.3

var target_position: Vector2:
	set(value):
		target_position = value
		look_at(Vector3(value.x, global_position.y, value.y), Vector3.UP, true)
		moving = true
		anim_tree.set("parameters/State/transition_request", "walk")


func _ready() -> void:
	if not anim_tree:
		anim_tree = find_child("AnimationTree")


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not physics_enabled:
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not moving:
		move_and_slide()
		return
	
	velocity = transform.basis.z * speed
	
	var current_position = Vector2(global_position.x, global_position.z)
	if current_position.distance_to(target_position) < 0.5:
		moving = false
		velocity = Vector3.ZERO
		anim_tree.set("parameters/State/transition_request", "idle")
	
	move_and_slide()
