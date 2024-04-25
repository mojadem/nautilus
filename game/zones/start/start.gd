extends XRToolsSceneBase

@onready var rock_detector: Area3D = $Areas/RockDetector
@onready var rock_splash: AudioStreamPlayer3D = $Sounds/RockSplash


func _ready() -> void:
	rock_detector.body_entered.connect(_on_rock_detected)
	
	XRToolsUserSettings.player_height = 1.6


func _on_rock_detected(body: Node3D) -> void:
	if not body.is_in_group("rock"):
		return

	rock_splash.global_position = body.global_position
	rock_splash.play()
	body.queue_free()
