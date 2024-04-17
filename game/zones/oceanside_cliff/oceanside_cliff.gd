extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var keys: XRToolsPickable = $Interactables/CarKeys
@onready var key_highlight: HighlightComponent = $Interactables/CarKeys/car_keys/metal/HighlightComponent
@onready var key_snap_zone: XRToolsSnapZone = $NavigationRegion3D/car/KeyHole/SnapZone

@onready var rock: XRToolsPickable = $Interactables/Rock
@onready var rock_highlight: HighlightComponent = $Interactables/Rock/rock/Cube_009/HighlightComponent
@onready var rock_snap_zone: XRToolsSnapZone = $Interactables/RockSnapZone
@onready var rock_splash: AudioStreamPlayer3D = $Sounds/RockSplash
@onready var rock_detector: Area3D = $RockDetector
@onready var dialog_delay: Timer = $RockDetector/DialogDelay

@onready var pat: Character = $Characters/PatAdult
@onready var pat_hand: XRToolsSnapZone = $Characters/PatAdult/RightHand/SnapZone

var current_dialog := 1
var awaiting_rock := false
var awaiting_key_pickup := false


func _ready() -> void:
	rock.picked_up.connect(_on_rock_picked_up)
	rock_detector.body_entered.connect(_on_rock_detected)
	animation_player.animation_finished.connect(_on_animation_finished)
	dialog_delay.timeout.connect(_on_dialog_delay_timeout)
	pat.arrived_at_marker.connect(_on_pat_arrived)

	animation_player.play("dialog_1")


func _on_rock_picked_up(_pickable: Variant) -> void:
	rock_highlight.highlight_enabled = false


func _on_rock_detected(body: Node3D) -> void:
	if not body.is_in_group("rock"):
		return

	rock_splash.global_position = rock.global_position
	rock_splash.play()
	rock_snap_zone.pick_up_object(rock)

	if not awaiting_rock:
		return

	awaiting_rock = false
	rock_highlight.highlight_enabled = false
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
			key_highlight.highlight_enabled = true
			awaiting_key_pickup = true
		"dialog_5":
			await_rock()
		"dialog_6":
			play_next_dialog()
		"dialog_7":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if not scene_base:
				return

			var target = ""
			scene_base.load_scene(target)


func _on_dialog_delay_timeout() -> void:
	play_next_dialog()


func _on_pat_arrived() -> void:
	if current_dialog == 2:
		pat.look_at_player = true

	if current_dialog == 4:
		keys.enabled = true
		pat_hand.pick_up_object(keys)


func await_rock() -> void:
	awaiting_rock = true
	rock_highlight.highlight_enabled = true


func play_next_dialog() -> void:
	match current_dialog:
		2:
			var marker: Marker3D = $Markers/Pat1
			pat.nav_target = marker
		4:
			var marker: Marker3D = $Markers/Pat2
			pat.nav_target = marker

	animation_player.play("dialog_%s" % current_dialog)


func _on_function_pickup_has_picked_up(what: Variant) -> void:
	if not awaiting_key_pickup:
		return

	if what == keys:
		key_highlight.highlight_enabled = false
		play_next_dialog()


func _on_keys_inserted(what: Variant) -> void:
	animation_player.play("dialog_6")
