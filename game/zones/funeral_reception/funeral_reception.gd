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


func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)
	drink_area.body_entered.connect(_on_sip)
	transition_area.body_entered.connect(_on_transition_area_entered)

	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog += 1
	match anim_name:
		"dialog_1":
			await_sip()
		"dialog_2":
			await_sip()
		"dialog_3":
			await_sip()
		"dialog_4":
			transition_area.monitoring = true
			doors_highlight.enabled = true
		"dialog_5":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			var target = "res://game/zones/living_room/living_room_2.tscn"
			scene_base.load_scene(target)
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


func _on_transition_area_entered(body: Node3D) -> void:
	play_next_dialog()


func await_sip():
	awaiting_sip = true
	whiskey_glass_highlight.enabled = true
