extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var bottom_cliff: Area3D = $Areas/BottomCliff
@onready var top_cliff: Area3D = $Areas/TopCliff

@onready var casey: Character = $Characters/CaseyYoung
@onready var pat: Character = $Characters/PatYoung

var current_dialog := 1


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	bottom_cliff.body_entered.connect(_on_bottom_cliff_entered)
	top_cliff.body_entered.connect(_on_top_cliff_entered)

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
			pass
		"dialog_4":
			pass
		"dialog_5":
			pass
		"dialog_6":
			pass


func play_next_dialog():
	animation_player.play("dialog_%s" % current_dialog)


func _on_bottom_cliff_entered(body: Node3D):
	play_next_dialog()
	bottom_cliff.monitoring = false


func _on_top_cliff_entered(body: Node3D):
	play_next_dialog()
	top_cliff.monitoring = false
