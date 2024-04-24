extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shell_highlight: HighlightComponent = $Interactables/FireplaceSnapZone/NautilusShell/nautilus_shell/shell/HighlightComponent
@onready var fireplace_snap_zone: XRToolsSnapZone = $Interactables/FireplaceSnapZone

var current_dialog := 1

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	fireplace_snap_zone.has_dropped.connect(_on_tv_snap_zone_has_dropped)

	var staging: XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	staging.scene_visible.connect(_on_scene_visible)


func _on_scene_visible(_scene: Variant, _user_data: Variant) -> void:
	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog += 1
	match anim_name:
		"dialog_1":
			shell_highlight.enabled = true
		"dialog_2":
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			var target = "res://game/zones/forest_lake/forest_lake.tscn"
			scene_base.load_scene(target)


func _on_tv_snap_zone_has_dropped() -> void:
	var transition_ready = current_dialog == 2
	if not transition_ready:
		return

	animation_player.play("dialog_2")
