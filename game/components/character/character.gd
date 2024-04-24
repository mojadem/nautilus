@tool
extends CharacterBody3D
class_name Character

@export var physics_enabled := false

@export var player: XRToolsPlayerBody
@export var look_at_player := false

@export var mesh: MeshInstance3D
@export_enum("Happy", "Sad", "Angry", "Surprised") var expression: int: set = _on_set_expression

@export var nav: NavigationAgent3D

var navigating = false
var nav_target: Marker3D: set = _on_set_nav_target

var anim_tree: AnimationTree

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed := 0.0
var max_speed := 1.3


func _on_set_expression(value: int) -> void:
	if not mesh:
		return

	expression = value
	var offset: float = float(expression) / 4.0
	var material: BaseMaterial3D = mesh.get_surface_override_material(1)
	if material:
		material.uv1_offset = Vector3(offset, 0, 0)


func _on_set_nav_target(value: Marker3D) -> void:
	nav_target = value
	navigating = true
	set_animation_state("walk")


func _ready() -> void:
	anim_tree = get_node("AnimationTree")
	anim_tree.animation_finished.connect(_on_animation_finished)

	nav = find_child("NavigationAgent3D")
	if nav:
		nav.navigation_finished.connect(_on_navigation_finished)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not physics_enabled:
		return

	velocity = Vector3.ZERO

	if navigating:
		navigate(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if look_at_player:
		set_head_turn(delta)
	else:
		var current_value = anim_tree.get("parameters/HeadTurn/blend_position")
		var value = lerpf(current_value, 0, delta * 4)
		anim_tree.set("parameters/HeadTurn/blend_position", value)


func _on_animation_finished(anim_name: StringName):
	if anim_name == "TurnLeftFull":
		global_rotate(Vector3.UP, PI / 2)
		anim_tree.set("parameters/TurnState/transition_request", "pass")

	if anim_name == "TurnRightFull":
		global_rotate(Vector3.UP, -PI / 2)
		anim_tree.set("parameters/TurnState/transition_request", "pass")


func _on_navigation_finished() -> void:
	navigating = false
	set_animation_state("idle")


func navigate(delta) -> void:
	var direction = Vector3()

	nav.target_position = nav_target.global_position

	direction = nav.get_next_path_position() - global_position
	direction.y = 0
	direction = direction.normalized()

	look_at(global_position + direction, Vector3.UP, true)

	speed = lerpf(speed, max_speed, delta * 4)
	velocity = direction * speed


func set_head_turn(delta: float) -> void:
	var to_player := (player.global_position - global_position).normalized()
	var angle := transform.basis.z.angle_to(to_player) / (PI / 2)
	angle = clampf(angle, 0, 1)

	var cross := transform.basis.z.cross(to_player)
	if cross.y > 0:
		angle *= -1

	var current_value = anim_tree.get("parameters/HeadTurn/blend_position")
	var value = lerpf(current_value, angle, delta * 4)
	anim_tree.set("parameters/HeadTurn/blend_position", value)


func set_animation_state(state: String) -> void:
	anim_tree.set("parameters/State/transition_request", state)


func rotate_to_player() -> void:
	look_at(player.global_position, Vector3.UP, true)
