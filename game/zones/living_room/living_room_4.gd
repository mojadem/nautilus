extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var phone_ring: AudioStreamPlayer3D = $Interactables/Phone/AudioStreamPlayer3D

@onready var phone_snap_zone: XRToolsSnapZone = $Interactables/Phone/PhoneBox/SnapZone
@onready var phone_highlight: HighlightComponent = $Interactables/Phone/Phone/MeshInstance3D/HighlightComponent
@onready var phone_box_highlight: HighlightComponent = $Interactables/Phone/PhoneBox/MeshInstance3D/HighlightComponent

@onready var door_area: Area3D = $Areas/DoorArea
@onready var door_highlight: HighlightComponent = $living_room/door/HighlightComponent

var current_dialog := 1
var awaiting_phone_hangup := false
var phone_ringing := false


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	phone_snap_zone.has_dropped.connect(_on_phone_snap_zone_has_dropped)
	phone_snap_zone.has_picked_up.connect(_on_phone_snap_zone_has_picked_up)
	door_area.body_entered.connect(_on_door_area_body_entered)
	
	var staging: XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	staging.scene_visible.connect(_on_scene_visible)


func _on_scene_visible(_scene: Variant, _user_data: Variant) -> void:
	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog += 1
	match anim_name:
		"dialog_1":
			phone_highlight.enabled = true
		"dialog_2":
			phone_box_highlight.enabled = true
			phone_snap_zone.enabled = true
			awaiting_phone_hangup = true
		"dialog_3":
			door_highlight.enabled = true
			door_area.monitoring = true
		"dialog_4":
			pass


func play_next_dialog() -> void:
	animation_player.play("dialog_%s" % current_dialog)
	match current_dialog:
		2:
			phone_snap_zone.enabled = false
			phone_highlight.enabled = false
		3:
			phone_box_highlight.enabled = false
			awaiting_phone_hangup = false
		4:
			phone_ring.stop()
			phone_highlight.enabled = false
			phone_ringing = false


func _on_phone_snap_zone_has_dropped() -> void:
	if current_dialog == 2:
		play_next_dialog()
	elif phone_ringing:
		assert(current_dialog == 4)
		play_next_dialog()
	else:
		return


func _on_phone_snap_zone_has_picked_up(_what: Variant) -> void:
	if not awaiting_phone_hangup:
		return

	play_next_dialog()


func _on_door_area_body_entered(_body: Node3D) -> void:
	assert(current_dialog == 4)
	phone_ring.play()
	phone_highlight.enabled = true
	phone_ringing = true
