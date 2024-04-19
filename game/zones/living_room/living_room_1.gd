extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var phone_ring: AudioStreamPlayer3D = $Interactables/Phone/AudioStreamPlayer3D
@onready var phone_ring_delay: Timer = $PhoneRingDelay

@onready var phone_snap_zone: XRToolsSnapZone = $Interactables/Phone/PhoneBox/SnapZone
@onready var phone_highlight: HighlightComponent = $Interactables/Phone/Phone/MeshInstance3D/HighlightComponent
@onready var phone_box_highlight: HighlightComponent = $Interactables/Phone/PhoneBox/MeshInstance3D/HighlightComponent

@onready var drawer_snap_zone: XRToolsSnapZone = $Interactables/InteractableEndTable3/SliderOrigin/InteractableSlider/Drawer/SnapZone
@onready var drawer_highlight: HighlightComponent = $Interactables/InteractableEndTable3/SliderOrigin/InteractableSlider/Drawer/MeshInstance3D/HighlightComponent

var current_dialog := 1
var phone_ringing = false
var awaiting_phone_hangup := false


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	phone_ring_delay.timeout.connect(_start_phone_ringing)
	phone_snap_zone.has_dropped.connect(_on_phone_snap_zone_has_dropped)
	phone_snap_zone.has_picked_up.connect(_on_phone_hangup)
	drawer_snap_zone.has_dropped.connect(_on_drawer_snap_zone_has_dropped)


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog += 1
	match anim_name:
		"dialog_1":
			phone_box_highlight.enabled = true
			awaiting_phone_hangup = true
		"dialog_2":
			drawer_highlight.enabled = true
		"dialog_3":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			var target = "res://game/zones/funeral_reception/funeral_reception.tscn"
			scene_base.load_scene(target)


func play_next_dialog() -> void:
	animation_player.play("dialog_%s" % current_dialog)


func _start_phone_ringing():
	phone_ring.play()
	phone_highlight.enabled = true
	phone_ringing = true


func _on_phone_snap_zone_has_dropped():
	if not phone_ringing:
		return

	phone_ring.stop()
	phone_ringing = false
	phone_snap_zone.enabled = false
	phone_highlight.enabled = false

	play_next_dialog()


func _on_phone_hangup(_what: Variant) -> void:
	if not awaiting_phone_hangup:
		return

	phone_box_highlight.enabled = false
	play_next_dialog()


func _on_drawer_snap_zone_has_dropped():
	var transition_ready = current_dialog == 3
	if not transition_ready:
		return

	drawer_highlight.enabled = false

	play_next_dialog()
