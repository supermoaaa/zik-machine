extends TextureButton


# Declare member variables here. Examples:

var file_to_load= "res://conf.cfg"
var save_song = "res://record/"
var song_name = "recorded.wav"
var recordingeffectmaster = AudioServer.get_bus_effect(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var configFile= ConfigFile.new()
	configFile.load(file_to_load) 
	if (configFile.has_section_key("OUTPUT", "song_save_path")):
		save_song = configFile.get_value("OUTPUT", "song_save_path")
	#configFile.close()



		
func _on_Rec_Button_toggled(button_pressed):

	if button_pressed:


		recordingeffectmaster.set_recording_active(true)
		
	else:

		recordingeffectmaster.set_recording_active(false)
		var final_recording = recordingeffectmaster.get_recording()
		final_recording.save_to_wav(save_song+song_name)
		
		var list_rec = []

		var file = File.new()		
		if not file.file_exists("res://record_path.sav"):
			print("No file detected")
			return
		if file.open("res://record_path.sav", File.READ) != 0:
			print("Error opening file")
			return
		
		while not file.eof_reached():
			list_rec.append(file.get_line())
		list_rec.append(str(save_song+song_name))
		file.close()
		

		if file.open("res://record_path.sav", File.WRITE) != 0:
			print("Error opening file")
			return

		for rec_file in list_rec:
			file.store_line(rec_file)
		file.close()
		var rep = self.get_tree()
		print(rep)
		#print(rep.get_node("body/File_rep"))
		#var app_rec = rep.get_node("main/body/File_rep").create_item("record")
		#app_rec.set_text(0, song_name)
		#rep.get_node("main/body").list_file.append([str(save_song+song_name)])
		


func _on_LineEdit_text_entered(new_text):
	song_name = new_text + ".wav"
