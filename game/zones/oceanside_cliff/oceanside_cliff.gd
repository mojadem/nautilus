extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var rock_pile_highlight: HighlightComponent = $Interactables/RockPile/HighlightComponent
@onready var rock_splash: AudioStreamPlayer3D = $Sounds/RockSplash
@onready var rock_detector: Area3D = $Areas/RockDetector
@onready var dialog_delay: Timer = $Areas/RockDetector/DialogDelay

@onready var bench_snap_zone: XRToolsSnapZone = $Interactables/BenchSnapZone
@onready var keys: XRToolsPickable = $Interactables/BenchSnapZone/CarKeys
@onready var key_highlight: HighlightComponent = $Interactables/BenchSnapZone/CarKeys/car_keys/metal/HighlightComponent
@onready var car_area: Area3D = $Areas/CarArea
@onready var car_snap_zone: XRToolsSnapZone = $Interactables/CarSnapZone
@onready var car_highlight: HighlightComponent = $NavigationRegion3D/car/Body/HighlightComponent
@onready var keyhole_highlight: HighlightComponent = $NavigationRegion3D/car/KeyHole/HighlightComponent

@onready var casey: Character = $Characters/CaseyAdult
@onready var pat: Character = $Characters/PatAdult
@onready var pat_anim_tree: AnimationTree = $Characters/PatAdult/AnimationTree
@onready var pat_hand: XRToolsSnapZone = $Characters/PatAdult/RightHand/SnapZone
@onready var pat_navigation: NavigationAgent3D = $Characters/PatAdult/NavigationAgent3D

var current_dialog := 1
var awaiting_rock := false
var awaiting_key_pickup := false


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	rock_detector.body_entered.connect(_on_rock_detected)
	dialog_delay.timeout.connect(_on_dialog_delay_timeout)
	pat_navigation.navigation_finished.connect(_on_pat_arrived)
	pat_hand.has_dropped.connect(_on_pat_hand_has_dropped)
	car_area.body_entered.connect(_on_car_area_entered)
	car_snap_zone.has_picked_up.connect(_on_keys_inserted)

	var staging: XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	staging.scene_visible.connect(_on_scene_visible)


func _on_scene_visible(_scene: Variant, _user_data: Variant) -> void:
	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	current_dialog += 1
	match anim_name:
		"dialog_1":
			#await_rock()
			play_next_dialog()
		"dialog_2":
			#await_rock()
			play_next_dialog()
		"dialog_3":
			#await_rock()
			play_next_dialog()
		"dialog_4":
			pat_anim_tree.set("parameters/State/transition_request", "hand_over")
			keys.visible = true
			key_highlight.enabled = true
			awaiting_key_pickup = true
			
		"dialog_5":
			car_area.monitoring = true
			car_highlight.enabled = true
		"dialog_6":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			var target = "res://game/zones/living_room/living_room_3.tscn"
			scene_base.load_scene(target)


func play_next_dialog() -> void:
	match current_dialog:
		2:
			var target: Marker3D = $Markers/Pat1
			pat.nav_target = target
		4:
			var target: Marker3D = $Markers/Pat2
			pat.nav_target = target

	animation_player.play("dialog_%s" % current_dialog)


func _on_rock_detected(body: Node3D) -> void:
	if not body.is_in_group("rock"):
		return

	rock_splash.global_position = body.global_position
	rock_splash.play()
	body.queue_free()

	if not awaiting_rock:
		return

	awaiting_rock = false
	rock_pile_highlight.enabled = false
	dialog_delay.start()


func _on_dialog_delay_timeout() -> void:
	play_next_dialog()


func _on_pat_arrived() -> void:
	if current_dialog == 2:
		pat.look_at_player = true

	if current_dialog == 4:
		bench_snap_zone.drop_object()
		pat_hand.pick_up_object(keys)
		keys.visible = false


func _on_pat_hand_has_dropped() -> void:
	assert(awaiting_key_pickup)

	key_highlight.enabled = false
	awaiting_key_pickup = false
	play_next_dialog()


func _on_car_area_entered(body: Node3D) -> void:
	assert(body is XRToolsPlayerBody)

	car_highlight.enabled = false
	keyhole_highlight.enabled = true

	var casey_target = $Markers/Casey1
	var pat_target = $Markers/Pat3

	casey.nav_target = casey_target
	pat.nav_target = pat_target


func _on_keys_inserted(_what: Variant) -> void:
	keyhole_highlight.enabled = false
	play_next_dialog()


func await_rock() -> void:
	awaiting_rock = true
	rock_pile_highlight.enabled = true
