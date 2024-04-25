extends XRToolsSceneBase

const WHISKEY_SIP = preload("res://assets/audio/sfx/funeral_reception/whiskey_sip.wav")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var drink_area: Area3D = $XROrigin3D/XRCamera3D/DrinkArea
@onready var mc_dialog: AudioStreamPlayer3D = $XROrigin3D/XRCamera3D/MCDialog
@onready var whiskey_glass: WhiskeyGlass = $Interactables/WhiskeyGlass
@onready var whiskey_glass_highlight: HighlightComponent = $Interactables/WhiskeyGlass/Mesh/Glass/HighlightComponent
@onready var transition_area: Area3D = $TransitionArea
@onready var doors_highlight: HighlightComponent = $"Models/doors/left-door/HighlightComponent"

var current_dialog := 1
var awaiting_sip := false

var next_scene := "res://game/zones/living_room/living_room_2.tscn"


func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)
	drink_area.body_entered.connect(_on_sip)
	transition_area.body_entered.connect(_on_transition_area_entered)

	var staging: XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	staging.scene_visible.connect(_on_scene_visible)


func _on_scene_visible(_scene: Variant, user_data: Variant) -> void:
	if user_data and user_data["selected"]:
		next_scene = "res://game/zones/start/start.tscn"
	
	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	if "dialog" in anim_name:
		current_dialog += 1

	match anim_name:
		"dialog_1":
			await_sip()
			animation_player.play("casey_sip")
		"dialog_2":
			await_sip()
			animation_player.play("casey_sip")
		"dialog_3":
			await_sip()
			animation_player.play("casey_sip")
		"dialog_4":
			transition_area.monitoring = true
			doors_highlight.enabled = true
		"dialog_5":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			scene_base.load_scene(next_scene)
		"sip":
			play_next_dialog()


func play_next_dialog():
	animation_player.play("dialog_%s" % current_dialog)


func _on_sip(body: Node3D) -> void:
	if not body.is_in_group("whiskey_glass"):
		return

	if not awaiting_sip:
		return

	awaiting_sip = false
	animation_player.play("sip")
	whiskey_glass.fill_percent -= 0.33
	whiskey_glass_highlight.enabled = false


func _on_transition_area_entered(_body: Node3D) -> void:
	doors_highlight.enabled = false
	play_next_dialog()


func await_sip():
	awaiting_sip = true
	whiskey_glass_highlight.enabled = true
