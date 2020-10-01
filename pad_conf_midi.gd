extends WindowDialog

var conf_machine = ""
var conf_file = "res://conf.cfg"
var pad = 16
var active_set = 0


func _ready():
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	conf_machine = configFile.get_value("MACHINE", "active_machine")
	configFile.load(conf_machine)
	pad = configFile.get_value("PAD CONF", "PAD_number")
	var midi_map = configFile.get_value("PAD CONF", "midi_set")
	
	$CenterMidi/GridContainer.columns = pad/4
	for bt in pad:
		var testbt = Button.new()
		#testbt.margin_top = 30
		#testbt.margin_bottom = 30
		testbt.text = str(midi_map[active_set][bt])
		testbt.name = "pad"+str(bt)
		testbt.toggle_mode = true
		$CenterMidi/GridContainer.add_child(testbt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
