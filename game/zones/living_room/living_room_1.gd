extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_snap_zone_has_dropped():
	animation_player.play("phone_call")
