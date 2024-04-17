extends XRToolsSceneBase

const WHISKEY_SIP = preload("res://assets/audio/sfx/funeral_reception/whiskey_sip.wav")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var drink_area: Area3D = $XROrigin3D/XRCamera3D/DrinkArea
@onready var mc_dialog: AudioStreamPlayer3D = $XROrigin3D/XRCamera3D/MCDialog
@onready var whiskey_glass: WhiskeyGlass = $Interactables/WhiskeyGlass
@onready var whiskey_glass_mesh: HighlightMesh = $Interactables/WhiskeyGlass/Glass
@onready var transition_area: Area3D = $TransitionArea

enum State {
	DIALOG_1,
	DIALOG_2,
	DIALOG_3,
	DIALOG_4,
	TRANSITION,
}

var state := State.DIALOG_1
var awaiting_sip := false


func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)
	drink_area.body_entered.connect(_on_sip)
	transition_area.body_entered.connect(_on_transition_area_entered)

	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"dialog_1":
			state = State.DIALOG_2
			await_sip()
		"dialog_2":
			state = State.DIALOG_3
			await_sip()
		"dialog_3":
			state = State.DIALOG_4
			await_sip()
		"dialog_4":
			state = State.TRANSITION
		"transition":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if not scene_base:
				return

			var target = ""
			scene_base.load_scene(target)
		"sip":
			play_next_animation()


func _on_sip(body: Node3D) -> void:
	if not body.is_in_group("whiskey_glass"):
		return

	if not awaiting_sip:
		return

	awaiting_sip = false
	animation_player.play("sip")
	whiskey_glass.fill_percent -= 0.33
	whiskey_glass_mesh.highlight_enabled = false


func _on_transition_area_entered(body: Node3D) -> void:
	if state != State.TRANSITION:
		return

	animation_player.play("transition")


func await_sip():
	awaiting_sip = true
	whiskey_glass_mesh.highlight_enabled = true


func play_next_animation():
	match state:
		State.DIALOG_2:
			animation_player.play("dialog_2")
		State.DIALOG_3:
			animation_player.play("dialog_3")
		State.DIALOG_4:
			animation_player.play("dialog_4")
