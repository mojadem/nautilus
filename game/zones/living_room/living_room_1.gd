extends XRToolsSceneBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var funeral_card: KeyItem = $Interactables/FuneralCard
@onready var mc_dialog: AudioStreamPlayer3D = $XROrigin3D/XRCamera3D/AudioStreamPlayer3D
@onready var phone_ring: AudioStreamPlayer3D = $Interactables/Phone/AudioStreamPlayer3D
@onready var phone_ring_delay: Timer = $PhoneRingDelay
@onready var phone_snap_zone: XRToolsSnapZone = $Interactables/Phone/PhoneBox/SnapZone

@onready var phone_mesh: HighlightMesh = $Interactables/Phone/Phone/HighlightMesh
@onready var phone_box_mesh: HighlightMesh = $Interactables/Phone/PhoneBox/HighlightMesh
@onready var drawer_mesh: HighlightMesh = $Interactables/InteractableEndTable3/SliderOrigin/InteractableSlider/Drawer/HighlightMesh

enum State {
	INITIAL,
	PHONE_RINGING,
	PHONE_CALL_STARTED,
	PHONE_CALL_ENDED,
	PHONE_HANGUP,
	TRANSITION
}

var state := State.INITIAL


func process_state():
	match state:
		State.PHONE_RINGING:
			phone_ring.play()
			phone_mesh.highlight_enabled = true
		
		State.PHONE_CALL_STARTED:
			phone_ring.stop()
			animation_player.play("phone_call")
			phone_snap_zone.enabled = false
			phone_mesh.highlight_enabled = false
		
		State.PHONE_CALL_ENDED:
			phone_snap_zone.enabled = true
			phone_box_mesh.highlight_enabled = true
		
		State.PHONE_HANGUP:
			mc_dialog.stream = load("res://assets/audio/dialog/living_room_1/mc/6.wav")
			mc_dialog.play()
			funeral_card.scene_switch_enabled = true
			phone_box_mesh.highlight_enabled = false
			drawer_mesh.highlight_enabled = true
		
		State.TRANSITION:
			mc_dialog.stream = load("res://assets/audio/dialog/living_room_1/mc/7.wav")
			mc_dialog.play()
			drawer_mesh.highlight_enabled = false


func _start_phone_ringing():
	state = State.PHONE_RINGING
	process_state()


func _start_phone_call():
	if state != State.PHONE_RINGING:
		return
	
	state = State.PHONE_CALL_STARTED
	process_state()


func _end_phone_call(_anim_name):
	if state != State.PHONE_CALL_STARTED:
		return
	
	state = State.PHONE_CALL_ENDED
	process_state()


func _hangup_phone(_what):
	if state != State.PHONE_CALL_ENDED:
		return
	
	state = State.PHONE_HANGUP
	process_state()


func _start_transition(_pickable):
	if state != State.PHONE_HANGUP:
		return
	
	state = State.TRANSITION
	process_state()


func _ready():
	phone_ring_delay.timeout.connect(_start_phone_ringing)
	phone_snap_zone.has_dropped.connect(_start_phone_call)
	animation_player.animation_finished.connect(_end_phone_call)
	phone_snap_zone.has_picked_up.connect(_hangup_phone)
	funeral_card.picked_up.connect(_start_transition)
