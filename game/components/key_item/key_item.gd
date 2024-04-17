extends XRToolsPickable

class_name KeyItem

@export_file("*.tscn") var zone_scene : String = ""
@export var scene_switch_enabled := false
@export var spawn_node_name := ""

@onready var timer: Timer = $Timer


func _on_picked_up(_pickable):
	if not scene_switch_enabled:
		return

	timer.start()


func _on_timer_timeout():
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return

	if zone_scene == "":
		scene_base.reset_scene(spawn_node_name)
	else:
		scene_base.load_scene(zone_scene, spawn_node_name)
