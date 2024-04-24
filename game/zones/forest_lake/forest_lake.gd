extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var bottom_cliff: Area3D = $Areas/BottomCliff
@onready var top_cliff: Area3D = $Areas/TopCliff
@onready var ear_area: Area3D = $XROrigin3D/XRCamera3D/EarArea
@onready var water_area: Area3D = $Areas/WaterArea
@onready var cliff_barrier: CollisionShape3D = $"NavigationRegion3D/forest_lake/cliff-barrier/CollisionShape3D"

@onready var cliff_snap_zone: XRToolsSnapZone = $Interactables/CliffSnapZone
@onready var shell: XRToolsPickable = $Interactables/CliffSnapZone/NautilusShell
@onready var shell_highlight: HighlightComponent = $Interactables/CliffSnapZone/NautilusShell/nautilus_shell/shell/HighlightComponent

@onready var casey: Character = $Characters/CaseyYoung

@onready var pat: Character = $Characters/PatYoung
@onready var pat_hand: XRToolsSnapZone = $Characters/PatYoung/RightHand/SnapZone
@onready var pat_anim_tree: AnimationTree = $Characters/PatYoung/AnimationTree
@onready var pat_visibility: VisibleOnScreenNotifier3D = $Characters/PatYoung/VisibleOnScreenNotifier3D

var current_dialog := 1
var awaiting_shell_pickup = false
var awaiting_pat_visibility = false
var awaiting_jump = false


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	bottom_cliff.body_entered.connect(_on_bottom_cliff_entered)
	top_cliff.body_entered.connect(_on_top_cliff_entered)
	pat_anim_tree.animation_finished.connect(_on_pat_animation_finished)
	pat_hand.has_dropped.connect(_on_pat_hand_has_dropped)
	ear_area.body_entered.connect(_on_ear_area_body_entered)
	pat_visibility.screen_entered.connect(_on_pat_visibility_screen_entered)
	water_area.body_entered.connect(_on_water_area_body_entered)

	var staging: XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	staging.scene_visible.connect(_on_scene_visible)


func _on_scene_visible(_scene: Variant, _user_data: Variant) -> void:
	animation_player.play("dialog_1")


func _on_animation_finished(anim_name: StringName) -> void:
	current_dialog +=1
	match anim_name:
		"dialog_1":
			var target := $Markers/Cliffside
			casey.nav_target = target
			pat.nav_target = target
		"dialog_2":
			pass
		"dialog_3":
			pat_anim_tree.set("parameters/State/transition_request", "start_hand_over")
		"dialog_4":
			ear_area.set_deferred("monitoring", true)
		"dialog_5":
			pass
		"dialog_6":
			if pat_visibility.is_on_screen():
				play_next_dialog()
			else:
				awaiting_pat_visibility = true
		"dialog_7":
			play_next_dialog()
		"dialog_8":
			awaiting_jump = true
			cliff_barrier.disabled = true

func play_next_dialog():
	match current_dialog:
		2:
			casey.physics_enabled = false

	animation_player.play("dialog_%s" % current_dialog)


func _on_bottom_cliff_entered(_body: Node3D):
	play_next_dialog()
	bottom_cliff.set_deferred("monitoring", false)


func _on_top_cliff_entered(_body: Node3D):
	assert(current_dialog <= 3)
	if current_dialog < 3:
		current_dialog = 3
	play_next_dialog()
	top_cliff.set_deferred("monitoring", false)


func _on_pat_animation_finished(anim_name: StringName) -> void:
	if anim_name == "HandOverStart_YoungAdult_female":
		cliff_snap_zone.enabled = true
		cliff_snap_zone.drop_object()
		pat_hand.pick_up_object(shell)
		shell.visible = true
		awaiting_shell_pickup = true
		shell_highlight.enabled = true


func _on_pat_hand_has_dropped() -> void:
	assert(awaiting_shell_pickup)

	shell_highlight.enabled = false
	play_next_dialog()


func _on_ear_area_body_entered(body: Node3D):
	assert(body.is_in_group("shell"))


	ear_area.set_deferred("monitoring", false)
	play_next_dialog()

func _on_pat_visibility_screen_entered() -> void:
	if not awaiting_pat_visibility:
		return

	awaiting_pat_visibility = false
	play_next_dialog()

func _on_water_area_body_entered(_body: Node3D) -> void:
	assert(awaiting_jump)

	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	var target = "res://game/zones/living_room/living_room_4.gd"
	scene_base.load_scene(target)
