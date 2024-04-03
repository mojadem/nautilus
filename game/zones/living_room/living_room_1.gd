extends XRToolsSceneBase

@onready var phone_ring_delay = $PhoneRingDelay
@onready var phone_snap_zone = $Interactables/Phone/PhoneBox/PhoneSnapZone
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var funeral_card: KeyItem = $Interactables/FuneralCard

@onready var phone_ring: AudioStreamPlayer3D = $Interactables/Phone/AudioStreamPlayer3D
@onready var mc_dialog: AudioStreamPlayer3D = $XROrigin3D/XRCamera3D/AudioStreamPlayer3D

enum State {
	INITIAL,
	PHONE_RINGING,
	PHONE_CALL_STARTED,
	PHONE_CALL_ENDED,
	PHONE_HANGUP,
	TRANSITION
}

var state_advancers = [
	phone_ring_delay.timeout,
	phone_snap_zone.has_dropped,
	animation_player.animation_finished,
	phone_snap_zone.has_picked_up,
	funeral_card.picked_up
]

var state := State.INITIAL


func advance_state():
	state += 1
	
	match state:
		State.PHONE_RINGING:
			phone_ring.play()
		
		State.PHONE_CALL_STARTED:
			phone_ring.stop()
			animation_player.play("phone_call")
			phone_snap_zone.enabled = false
		
		State.PHONE_CALL_ENDED:
			phone_snap_zone.enabled = true
		
		State.PHONE_HANGUP:
			mc_dialog.stream = load("res://assets/audio/dialog/living_room_1/mc/6.wav")
			mc_dialog.play()
			funeral_card.scene_switch_enabled = true
		
		State.TRANSITION:
			mc_dialog.stream = load("res://assets/audio/dialog/living_room_1/mc/7.wav")
			mc_dialog.play()


func _ready():
	for s in state_advancers:
		s.connect(advance_state)
