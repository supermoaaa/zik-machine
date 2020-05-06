extends ColorRect


var tempo = 461.0
var time = 0.0
var last_ticks = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	last_ticks = OS.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	time = OS.get_ticks_msec()
	#print(time - last_ticks)
	if $ButtonMetro.pressed == true:
		if time - last_ticks >= tempo:
			$AudioMetronome.play()
			last_ticks = time


func _on_SpinBox_value_changed(value):
	tempo = 60000/value


func _on_Vol_Slider_tempo_value_changed(value):
	$AudioMetronome.volume_db = value


func _on_Button_toggled(button_pressed):
	if button_pressed == false:
		$AudioMetronome.stream = load("res://utils/tic_classic.wav")
		$sound.text = "classic"
	else:
		$AudioMetronome.stream = load("res://utils/tic_old.wav")
		$sound.text = "old tic"
