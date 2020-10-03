extends WindowDialog

var conf_machine = ""
var conf_file = "res://conf.cfg"
var pad = 16
var active_set = 0
var midi_map = []


func _ready():
	var configFile = ConfigFile.new()
	configFile.load(conf_file)
	conf_machine = configFile.get_value("MACHINE", "active_machine")
	configFile.load(conf_machine)
	pad = configFile.get_value("PAD CONF", "PAD_number")
	midi_map = configFile.get_value("PAD CONF", "midi_set")
	
	$CenterMidi/GridContainer.columns = pad/4
	for bt in pad:
		var testbt = Button.new()
		#testbt.margin_top = 30
		#testbt.margin_bottom = 30
		testbt.text = str(midi_map[active_set][bt])
		testbt.name = str(bt)
		testbt.toggle_mode = true
		testbt.connect("button_down", self, "midi_learn", [bt])
		testbt.add_to_group("midi_bt")
		$CenterMidi/GridContainer.add_child(testbt)

func midi_learn(bt):
	var active_bt = get_node("CenterMidi/GridContainer/"+str(bt))
	if not active_bt.text == "learn":
		#old_key = active_bt.text
		active_bt.text = "learn"
	else:
		active_bt.text = str(midi_map[active_set][bt])
	
	var midi_bt_node = get_tree().get_nodes_in_group("midi_bt")
	
	for midi_bt in midi_bt_node:
		if not midi_bt == active_bt:
			if midi_bt.pressed == true:
				midi_bt.text = str(midi_map[active_set][int(midi_bt.name)])
			midi_bt.pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
