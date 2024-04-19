extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var keys_highlight: HighlightComponent = $Interactables/TVSnapZone/CarKeys/car_keys/metal/HighlightComponent
@onready var tv_snap_zone: XRToolsSnapZone = $Interactables/TVSnapZone

var current_dialog := 1


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	tv_snap_zone.has_dropped.connect(_on_tv_snap_zone_has_dropped)

	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog += 1
	match anim_name:
		"dialog_1":
			keys_highlight.enabled = true
		"dialog_2":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			var target = "res://game/zones/oceanside_cliff/oceanside_cliff.tscn"
			scene_base.load_scene(target)


func _on_tv_snap_zone_has_dropped() -> void:
	var transition_ready = current_dialog == 2
	if not transition_ready:
		return

	animation_player.play("dialog_2")
