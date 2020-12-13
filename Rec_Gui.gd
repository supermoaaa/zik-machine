extends TextureButton


func _ready():
	pass # Replace with function body.

#very bad part just for line edit bug

func _on_LineEdit_text_entered(_new_text):
	if $LineEdit.editable == true:
		$LineEdit.editable = false
	else:
		$LineEdit.editable = true



func _on_LineEdit_gui_input(event):
	if event is InputEventMouseButton:
		if $LineEdit.editable == false:
			$LineEdit.editable = true

