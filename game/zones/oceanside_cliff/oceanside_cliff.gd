extends XRToolsSceneBase

@onready var rock_detector: Area3D = $RockDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var pat: Character = $Characters/PatAdult

enum State {
	DIALOG_1,
	DIALOG_2,
	DIALOG_3,
	DIALOG_4,
	DIALOG_5,
	DIALOG_6,
	DIALOG_7
}

var awaiting_rock := false


func _ready() -> void:
	rock_detector.body_entered.connect(_on_rock_detected)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	var marker: Marker3D = $Marker3D
	
	pat.target_position = Vector2(marker.global_position.x, marker.global_position.z)


func _on_rock_detected(body: Node3D) -> void:
	if not body.is_in_group("rock"):
		return
	
	if not awaiting_rock:
		return
	
	if body.is_in_group("rock"):
		awaiting_rock = false


func _on_animation_finished(anim_name: StringName) -> void:
	pass
