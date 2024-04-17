@tool
extends CharacterBody3D
class_name Character

signal arrived_at_marker

@export var physics_enabled := false

@export var player: XRToolsPlayerBody
@export var look_at_player := false

@export var mesh: MeshInstance3D
@export_enum("Happy", "Sad", "Angry", "Surprised") var expression: int: set = _on_set_expression

@export var nav: NavigationAgent3D

var nav_target: Marker3D

var anim_tree: AnimationTree

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed := 1.3


func _on_set_expression(value: int) -> void:
	if not mesh:
			return

	expression = value
	var offset: float = float(value) / 4.0
	var material: BaseMaterial3D = mesh.get_surface_override_material(1)
	material.uv1_offset = Vector3(offset, 0, 0)


func _on_set_nav_target(value: Marker3D) -> void:
	nav_target = value


func _ready() -> void:
	anim_tree = get_node("AnimationTree")
	nav = get_node("NavigationAgent3D")
	
	if nav:
		nav.navigation_finished.connect(_on_navigation_finished)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not physics_enabled:
		return
	
	if nav_target:
		navigate()
	
	check_state()

	if not is_on_floor():
		velocity.y -= gravity * delta

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


func _on_navigation_finished():
	pass


func navigate():
	var direction = Vector3()
	
	nav.target_position = nav_target.global_position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	look_at(direction, Vector3.UP, true)
	
	velocity = direction * speed


func check_state():
	var state = anim_tree.get("parameters/State/current_state")
	
	var moving := not velocity.is_zero_approx()
	
	if moving and state != "walk":
		anim_tree.set("parameters/State/transition_request", "walk")
	
	if not moving and state != "idle":
		anim_tree.set("parameters/State/transition_request", "idle")
