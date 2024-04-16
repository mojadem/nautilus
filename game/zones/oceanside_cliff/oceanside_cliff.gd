extends XRToolsSceneBase

@onready var rock_detector: Area3D = $RockDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var rock: XRToolsPickable = $Interactables/Rock
@onready var rock_highlight_component: Node3D = $Interactables/Rock/rock/Cube_009/HighlightComponent
@onready var rock_snap_zone: XRToolsSnapZone = $Interactables/RockSnapZone
@onready var rock_splash: AudioStreamPlayer3D = $Sounds/RockSplash
@onready var dialog_delay: Timer = $RockDetector/DialogDelay

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

var current_dialog := 1
var awaiting_rock := false


func _ready() -> void:
	rock_detector.body_entered.connect(_on_rock_detected)
	animation_player.animation_finished.connect(_on_animation_finished)
	dialog_delay.timeout.connect(_on_dialog_delay_timeout)
	
	animation_player.play("dialog_1")


func _on_rock_detected(body: Node3D) -> void:
	if not body.is_in_group("rock"):
		return
	
	rock_splash.global_position = rock.global_position
	rock_splash.play()
	rock_snap_zone.pick_up_object(rock)
	
	if not awaiting_rock:
		return
	
	awaiting_rock = false
	rock_highlight_component.highlight_enabled = false
	dialog_delay.start()


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog += 1
	match anim_name:
		"dialog_1":
			await_rock()
		"dialog_2":
			await_rock()
		"dialog_3":
			await_rock()
		"dialog_4":
			await_rock()
		"dialog_5":
			await_rock()
		"dialog_6":
			await_rock()
		"dialog_7":
			await_rock()


func _on_dialog_delay_timeout() -> void:
	play_next_dialog()


func await_rock() -> void:
	awaiting_rock = true
	rock_highlight_component.highlight_enabled = true


func play_next_dialog() -> void:
	match current_dialog:
		2:
			var marker: Marker3D = $Markers/Pat1
			pat.move_to_marker(marker, 20.0)
	
	animation_player.play("dialog_%s" % current_dialog)
