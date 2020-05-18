extends TextureButton


# Declare member variables here. Examples:

var file_to_load= "res://conf.cfg"
var save_song = "res://record/"
var recordingeffectmaster = AudioServer.get_bus_effect(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var configFile= ConfigFile.new()
	configFile.load(file_to_load) 
	if (configFile.has_section_key("OUTPUT", "song_save_path")):
		save_song = configFile.get_value("OUTPUT", "song_save_path")


func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		self.ACTION_MODE_BUTTON_PRESS
		
func _on_Rec_Button_toggled(button_pressed):

	if button_pressed:

		print(save_song)
		recordingeffectmaster.set_recording_active(true)
		
	else:
		print("stop")

		recordingeffectmaster.set_recording_active(false)
		var final_recording = recordingeffectmaster.get_recording()
		final_recording.save_to_wav(save_song+"test.wav")

