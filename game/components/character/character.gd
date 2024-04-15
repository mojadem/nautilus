@tool
extends CharacterBody3D
class_name Character

@export var mesh: MeshInstance3D
@export var anim_tree: AnimationTree

@export_enum("Happy", "Sad", "Angry", "Surprised") var expression: int:
	set(value):
		if not mesh:
			return
		
		expression = value
		var offset: float = float(value) / 4.0
		var material: BaseMaterial3D = mesh.get_surface_override_material(1)
		material.uv1_offset = Vector3(offset, 0, 0)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var moving := false
var speed := 5.0

var target_position: Vector3:
	set(value):
		target_position = value
		moving = true


func _ready() -> void:
	if not anim_tree:
		anim_tree = find_child("AnimationTree")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not moving:
		return
	
	if target_position:
		global_position = global_position.move_toward(target_position, speed * delta)
	
	if global_position == target_position:
		moving = false
