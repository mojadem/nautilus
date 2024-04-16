@tool
extends CharacterBody3D
class_name Character

signal arrived_at_marker

@export var physics_enabled := false
@export var mesh: MeshInstance3D

@export var look_at_player := false
@export var player: XRToolsPlayerBody

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


var target: Marker3D


func move_to_marker(marker: Marker3D, duration: float) -> void:
	target = marker
	look_at(marker.global_position, Vector3.UP, true)
	moving = true
	anim_tree.set("parameters/State/transition_request", "walk")
	
	speed = global_position.distance_to(target.global_position) / duration


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
	
	if global_position.distance_to(target.global_position) < 0.5:
		moving = false
		velocity = Vector3.ZERO
		anim_tree.set("parameters/State/transition_request", "idle")
		basis = target.basis
		arrived_at_marker.emit()
	
	move_and_slide()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not player or not look_at_player:
		return
	
	var to_player := (player.global_position - global_position).normalized()
	var angle := transform.basis.z.angle_to(to_player) / (PI / 2)
	angle = clampf(angle, 0, 1)
	
	var cross := transform.basis.z.cross(to_player)
	if cross.y > 0:
		angle *= -1
	
	anim_tree.set("parameters/HeadTurn/blend_position", angle)
